import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayInit,
  SubscribeMessage,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: true,
})
export class RealtimeGateway implements OnGatewayInit {
  @WebSocketServer()
  server: Server;

  afterInit() {
    console.log('WebSocket iniciado');
  }

  @SubscribeMessage('subscribe_device')
  handleSubscribeDevice(client: Socket, deviceId: string) {
    client.join(deviceId); // Únete al room con nombre del deviceId
    console.log(`[WS] Cliente ${client.id} suscrito al deviceId: ${deviceId}`);
  }

  enviarDatosTiempoReal(deviceId: string, payload: any) {
    this.server.to(deviceId).emit('agua_live_update', payload);
  }
}
