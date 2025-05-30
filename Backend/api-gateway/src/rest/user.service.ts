import { Injectable } from '@nestjs/common';
import { connect } from 'mqtt';

@Injectable()
export class UserService {
  private client = connect('mqtt://localhost:1883');

  constructor() {}

  async registerUser(user: any): Promise<any> {
    return new Promise((resolve,reject)=>{
        this.client.publish(
        'user/register',
        JSON.stringify(user),
        { qos: 1 },
        (err) => {
          if (err) reject('No se pudo enviar');
          else resolve('Usuario registrado');
        },
      );
    });
  }
}
