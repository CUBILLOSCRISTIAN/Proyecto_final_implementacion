import { Body, Controller, Post } from '@nestjs/common';
import { UserService } from './user.service';

@Controller('usuario')
export class UsuarioController {
  constructor(private readonly usuarioService: UserService) {}

  @Post()
  async crearUsuario(@Body() user: any) {
    return this.usuarioService.registerUser(user);
  }
}
