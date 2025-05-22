import 'package:flow_sensor_app/modules/device_summary/agua_live_update_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  late IO.Socket socket;

  void connectToWebSocket(String deviceId, Function(AguaLiveUpdate) onData) {
    print('🔌 Conectando al WebSocket...');

    // Configuración del socket
    print("deviceId: $deviceId");

    ;
    socket = IO.io(
      'http://135.234.192.12:80',
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or dart VM
          .disableAutoConnect() // no conectar automáticamente
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Conectado al WebSocket');
      socket.emit('subscribe_device', deviceId); // Emitimos el evento
    });

    socket.on('agua_live_update', (data) {
      print('📡 Actualización recibida: $data');
      final model = AguaLiveUpdate.fromJson(data); // Parseas según tu modelo
      onData(model);
    });

    socket.onDisconnect((_) => print('❌ Desconectado'));
  }

  void disconnect() {
    socket.dispose();
  }
}
