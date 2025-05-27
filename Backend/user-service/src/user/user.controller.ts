import { Controller, Logger } from '@nestjs/common';
import { UserService } from './user.service';
import { Ctx, EventPattern, MqttContext, Payload } from '@nestjs/microservices';
import { plainToInstance } from 'class-transformer';
import { UserDto } from './dto/create-user.dto';
import { validate } from 'class-validator';

@Controller('user')
export class UserController {
  private readonly logger = new Logger(UserController.name);
  constructor(private readonly userService: UserService) {}

  @EventPattern('user/create')
  async handleCreateUser(@Payload() payload: any, @Ctx() context: MqttContext) {
    try {
      const user = plainToInstance(UserDto, payload);
      const errors = await validate(user, {
        whitelist: true,
        forbidNonWhitelisted: true,
      });

      if (errors.length > 0) {
        this.logger.warn(`Invalid config received: ${JSON.stringify(errors)}`);
        return;
      }

      this.userService.save(payload);
    } catch (error) {
      this.logger.error('Failed to handle MQTT message', error);
    }
  }
}
