#include <WiFi.h>
#include <Preferences.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "time.h"


// ------------------- Manejo de datos persistentes y control ---------------

Preferences prefs;
bool requiereReinicio = false;

// ------------------- Configuración WiFi y MQTT -------------------
char ssid[32];
char password[64];

char mqtt_server[32];
int mqtt_port;
char* mqtt_data_topic = "agua/medicion";

char* deviceId = "esp32-agua-01";

char mqtt_config_topic[50];


WiFiClient espClient;
PubSubClient client(espClient);

// ------------------- Variables del sensor -------------------
volatile int pulseCount = 0;
float flowRate = 0;
float totalLitres = 0;
float lastLitres = 0;

const byte flowSensorPin = 15;
float calibrationFactor = 7.5;  // Pulsos por segundo por L/min

// ------------------- Interrupción -------------------
void IRAM_ATTR countPulse() {
  pulseCount++;
}

// ------------------- Tarea: Medición -------------------
void TareaSensor(void* parameter) {
  unsigned long lastMillis = 0;

  while (true) {
    unsigned long currentMillis = millis();

    if (currentMillis - lastMillis >= 3000) {  // Cada 3 segundo
      detachInterrupt(digitalPinToInterrupt(flowSensorPin));

      float frequency = pulseCount;              // Pulsos por segundo
      flowRate = frequency / calibrationFactor;  // L/min

      float litresPerSecond = flowRate / 60.0;
      lastLitres += litresPerSecond;
      totalLitres += litresPerSecond;

      Serial.print("[Sensor] Flujo: ");
      Serial.print(flowRate);
      Serial.print(" L/min\t Litros: ");
      Serial.print(litresPerSecond, 4);
      Serial.print("\t Total: ");
      Serial.print(totalLitres, 3);
      Serial.println(" L");

      pulseCount = 0;
      lastMillis = currentMillis;

      attachInterrupt(digitalPinToInterrupt(flowSensorPin), countPulse, RISING);
    }

    vTaskDelay(10 / portTICK_PERIOD_MS);  // Pequeña pausa para liberar CPU
  }
}

// ------------------- Tarea: MQTT-Data -------------------
void TareaMQTT(void* parameter) {
  while (!client.connected()) {
    Serial.println("[MQTT] Conectando...");
    if (client.connect(deviceId)) {
      Serial.println("[MQTT] Conectado al broker");
      client.subscribe(mqtt_config_topic);
      Serial.print("[MQTT] Suscrito a: ");
      Serial.println(mqtt_config_topic);
    } else {
      Serial.print("[MQTT] Fallo. Estado: ");
      Serial.println(client.state());
      delay(2000);
    }
  }

  unsigned long lastSend = 0;

  while (true) {
    client.loop();

    unsigned long now = millis();
    if (now - lastSend > 10000) {  // Envio cada 10 seg
      if (lastLitres > 0) {
        // Obtener hora UTC
        time_t now;
        time(&now);
        struct tm* timeinfo = gmtime(&now);
        char timeString[30];
        strftime(timeString, sizeof(timeString), "%Y-%m-%dT%H:%M:%SZ", timeinfo);

        // Construir JSON
        StaticJsonDocument<256> doc;
        doc["deviceId"] = deviceId;
        doc["timestamp"] = timeString;
        doc["flowRate"] = flowRate;
        doc["litres"] = lastLitres;
        doc["totalLitres"] = totalLitres;

        char jsonBuffer[256];
        serializeJson(doc, jsonBuffer);

        // Enviar por MQTT
        client.publish(mqtt_data_topic, jsonBuffer);
        Serial.println("[MQTT] Enviado:");
        Serial.println(jsonBuffer);

        lastLitres = 0;
      }

      lastSend = now;
    }

    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}

// ------------------- Tarea: MQTT-Config -------------------

void callback(char* topic, byte* payload, unsigned int length) {

  String topicStr = String(topic);

  if (topicStr == mqtt_config_topic) {
    Serial.println("📩 Mensaje MQTT recibido");

    // Convertir payload a string
    String jsonStr;
    for (unsigned int i = 0; i < length; i++) {
      jsonStr += (char)payload[i];
    }

    Serial.println("🔍 JSON recibido:");
    Serial.println(jsonStr);

    StaticJsonDocument<512> doc;
    DeserializationError error = deserializeJson(doc, jsonStr);
    if (error) {
      Serial.print("❌ Error al parsear JSON: ");
      Serial.println(error.c_str());
      return;
    }

    prefs.begin("config", false);

    if (doc.containsKey("wifiSSID")) {
      prefs.putString("wifiSSID", doc["wifiSSID"].as<String>());
      requiereReinicio = true;
    }
    if (doc.containsKey("wifiPassword")) {
      prefs.putString("wifiPass", doc["wifiPassword"].as<String>());
      requiereReinicio = true;
    }
    if (doc.containsKey("mqttHost")) {
      prefs.putString("mqttHost", doc["mqttHost"].as<String>());
      requiereReinicio = true;
    }
    if (doc.containsKey("mqttPort")) {
      prefs.putInt("mqttPort", doc["mqttPort"].as<int>());
      requiereReinicio = true;
    }
    if (doc.containsKey("calibrationFactor")) {
      prefs.putFloat("calFactor", doc["calibrationFactor"].as<float>());
    }

    prefs.end();

    Serial.println("✅ Configuración actualizada");

    if (requiereReinicio) {
      Serial.println("🔁 Reiniciando en 3 segundos para aplicar cambios...");
      delay(3000);
      ESP.restart();
    }
  }
}

// ------------------- Setup de WiFi y NTP -------------------
void conectarWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("[WiFi] Conectando");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n[WiFi] Conectado");

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.println("[NTP] Configurado");
}

// ------------------ Setup Configuraciones ------------------

void guardarConfiguracion(String ssid, String pass, String host, int port, float factor) {
  prefs.begin("config", false);
  prefs.putString("wifiSSID", ssid);
  prefs.putString("wifiPass", pass);
  prefs.putString("mqttHost", host);
  prefs.putInt("mqttPort", port);
  prefs.putFloat("calFactor", factor);
  prefs.end();
}

// void guardarConfiguracion() {
//   prefs.begin("config", false);
//   prefs.putString("wifiSSID", "SANYVAL");
//   prefs.putString("wifiPass", "sanyval1224");
//   prefs.putString("mqttHost", "192.168.1.15");
//   prefs.putInt("mqttPort", 1883);
//   prefs.putFloat("calFactor", 7.5);
//   prefs.end();
// }

void cargarConfiguracion() {
  prefs.begin("config", true);

  String s;

  s = prefs.getString("wifiSSID", "SANYVAl").c_str();
  s.toCharArray(ssid, sizeof(ssid));
  s = prefs.getString("wifiPass", "sanyval1224").c_str();
  s.toCharArray(password, sizeof(password));
  s = prefs.getString("mqttHost", "192.168.1.15").c_str();
  s.toCharArray(mqtt_server, sizeof(mqtt_server));
  mqtt_port = prefs.getInt("mqttPort", 1883);
  calibrationFactor = prefs.getFloat("calFactor", 7.5);
  prefs.end();

  Serial.println("📦 Configuración cargada:");
  Serial.println("SSID: ");
  Serial.print(ssid);
  Serial.println("Password: ");
  Serial.print(password);
  Serial.println("MQTT Host: ");
  Serial.print(mqtt_server);
  Serial.println("MQTT Port: " + String(mqtt_port));
  Serial.println("Calibration Factor: " + String(calibrationFactor));
}

// ------------------- Setup principal -------------------
void setup() {
  Serial.begin(115200);
  delay(1000);  // Esperar a que el monitor abra

  // guardarConfiguracion();

  // Cargar configuraciones
  cargarConfiguracion();

  delay(1000);

  snprintf(mqtt_config_topic, sizeof(mqtt_config_topic), "agua/config/%s", deviceId);

  pinMode(flowSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(flowSensorPin), countPulse, RISING);

  conectarWiFi();

  client.setServer(mqtt_server, mqtt_port);

  client.setCallback(callback);

  // Crear la tarea para el sensor
  xTaskCreatePinnedToCore(TareaSensor, "Tarea Sensor", 4096, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(TareaMQTT, "Tarea MQTT", 8192, NULL, 1, NULL, 1);
}

void loop() {
}
