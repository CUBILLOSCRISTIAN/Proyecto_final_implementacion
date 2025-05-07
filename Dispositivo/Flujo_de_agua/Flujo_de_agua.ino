#include <WiFi.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <ArduinoJson.h>
#include <time.h>

// Identificador de dispositivo(Dirección MAC)
String deviceID;

// Permanencia de ultimo dato
Preferences preferences;
String bufferedPayload = "";
String bufferdSettings = "";

// Datos de conexion
String ssid = "proyecto";
String password = "test1234";

// URL de tu endpoint
String serverURL = "https://webhook.site/a544fb1d-3da5-48c0-a8d6-dae42e0dc5d7";

// Mutex para proteger acceso a pulseCount
portMUX_TYPE mux = portMUX_INITIALIZER_UNLOCKED;

// Variables de lectura de sensor
volatile int pulseCount = 0;
float calibrationFactor = 7.5;  // Según la fórmula del sensor

float flowRate;
float flowLitres;
float totalLitres = 0;
const int sensorPin = 15;

// Configuración de temporizadores
unsigned long previousMillis = 0;
unsigned long previousSendMillis = 0;  // Tiempo para enviar datos
const long sendInterval = 10000;       // Enviar cada 60 segundos (1 minuto)

// Prototipos
void IRAM_ATTR pulseCounter();
void readFlow(void* parameter);
void sendData(void* parameter);

void setup() {
  Serial.begin(115200);
  pinMode(sensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(sensorPin), pulseCounter, RISING);
  Serial.println("Contador de flujo iniciado");

  // Cargar último JSON guardado
  preferences.begin("flow-data", false);  // Espacio de nombres "flow-data"
  bufferedPayload = preferences.getString("lastJSON", "");
  preferences.end();

  if (bufferdSettings != "") {
    Serial.println("Cargando configuraciones desde memoria:");
    Serial.println(bufferdSettings);

    // Parsear JSON
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, bufferdSettings);
    if (!error) {
      float recoveredCalibrationFactor = doc["calibrationFactor"];
      ssid = String(doc["ssid"].as<const char*>());
      password = String(doc["password"].as<const char*>());
      serverURL = String(doc["serverURL"].as<const char*>());
      calibrationFactor = recoveredCalibrationFactor;
      Serial.printf("Configuracion restaurada: ", bufferdSettings);
    } else {
      Serial.println("Error al parsear JSON guardado.");
    }
  }

  if (bufferedPayload != "") {
    Serial.println("Dato pendiente cargado desde memoria:");
    Serial.println(bufferedPayload);

    // Parsear JSON
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, bufferedPayload);
    if (!error) {
      float recoveredTotal = doc["totalVolume"];
      totalLitres = recoveredTotal;
      Serial.printf("Volumen total restaurado: %.3f L\n", totalLitres);
    } else {
      Serial.println("Error al parsear JSON guardado.");
    }
  }

  delay(5000);
  Serial.print("SSID: ");
  Serial.println(ssid.c_str());
  Serial.print("Contraseña: ");
  Serial.println(password.c_str());

  // Conexión WiFi
  WiFi.begin(ssid.c_str(), password.c_str());
  Serial.print("Conectando a WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n¡WiFi conectado!");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());

  // Obtener y limpiar el Identificador de dispositivo(Dirección MAC)
  deviceID = WiFi.macAddress();
  deviceID.replace(":", "");
  Serial.print("🆔 DeviceID: ");
  Serial.println(deviceID);

  // Configurar hora vía NTP (zona horaria UTC-5 para Colombia)
  configTime(-5 * 3600, 0, "pool.ntp.org", "time.nist.gov");

  Serial.println("⏳ Sincronizando hora...");
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("❌ Error al obtener hora NTP.");
  } else {
    Serial.println("✅ Hora NTP sincronizada.");
  }

  // Crear tareas
  xTaskCreate(readFlow, "Leer Flujo", 2048, NULL, 1, NULL);
  xTaskCreate(sendData, "Enviar Datos", 8192, NULL, 1, NULL);
}

void loop() {
  // Monitorear el uso de memoria en el heap
  Serial.printf("Memoria libre en heap: %d bytes\n", esp_get_free_heap_size());

  // Monitorear la pila de las tareas
  UBaseType_t stackHighWaterMark = uxTaskGetStackHighWaterMark(NULL);
  Serial.printf("Pila restante en la tarea principal: %d bytes\n", stackHighWaterMark);

  delay(5000);  // Actualizar cada 5 segundos
}

void IRAM_ATTR pulseCounter() {
  portENTER_CRITICAL_ISR(&mux);
  pulseCount++;
  portEXIT_CRITICAL_ISR(&mux);
}

// Tarea de lectura
void readFlow(void* parameter) {
  while (true) {
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= 1000) {
      int pulses = 0;

      // Proteger lectura
      portENTER_CRITICAL(&mux);
      pulses = pulseCount;
      pulseCount = 0;
      portEXIT_CRITICAL(&mux);

      flowRate = pulses / calibrationFactor;  // L/min
      flowLitres = pulses / 450.0;            // Litros por segundo
      totalLitres += flowLitres;

      Serial.printf("Flujo: %.2f L/min | Volumen: %.3f L | Total: %.3f L\n", flowRate, flowLitres, totalLitres);
      previousMillis = currentMillis;
    }
    vTaskDelay(pdMS_TO_TICKS(100));  // Retrasar para evitar consumir demasiada CPU
  }
}

// Tarea de envío
void sendData(void* parameter) {
  while (true) {
    unsigned long currentMillis = millis();
    StaticJsonDocument<256> doc;
    doc["deviceID"] = deviceID;
    doc["flowRate"] = flowRate;
    doc["secVolume"] = flowLitres;
    doc["totalVolume"] = totalLitres;

    // Obtener tiempo actual y formatear
    struct tm timeinfo;
    if (getLocalTime(&timeinfo)) {
      char timestamp[25];
      strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%S", &timeinfo);  // Formato ISO 8601
      doc["timestamp"] = timestamp;
    } else {
      doc["timestamp"] = "unsynced";
    }

    String payload;
    serializeJson(doc, payload);

    if (currentMillis - previousSendMillis >= sendInterval) {
      if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        http.begin(serverURL.c_str());
        http.addHeader("Content-Type", "application/json");

        int httpResponseCode = http.POST(payload);

        if (httpResponseCode >= 200 && httpResponseCode < 300) {
          Serial.printf("Enviado correctamente. Código HTTP %d\n", httpResponseCode);
        } else {
          Serial.printf("Error en la conexión HTTP. Código %d\n", httpResponseCode);
        }

        http.end();
      } else {
        Serial.println("🚫 Sin WiFi. Guardando último dato...");
      }

      preferences.begin("flow-data", false);
      preferences.putString("lastJSON", payload);
      preferences.end();
      bufferedPayload = payload;

      previousSendMillis = currentMillis;
    }
    vTaskDelay(pdMS_TO_TICKS(500));  // Retrasar para evitar consumo excesivo de CPU
  }
}
