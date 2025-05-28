import { Controller } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { EventPattern, Payload } from '@nestjs/microservices';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @EventPattern(process.env.MQTT_TOPIC)
  async handleNotificationEvent(@Payload() data:any) {
    // Handle the incoming notification event
    console.log('Received notification event:', data);
    await this.notificationsService.VerificarLimites(data);
  }
}
