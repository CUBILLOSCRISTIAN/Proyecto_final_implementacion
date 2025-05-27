import { IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class UserDto {
  @IsString()
  deviceId: string;

  @IsNumber()
  @Min(0)
  limiteDiario: number;

  @IsNumber()
  @Min(0)
  limiteMensual: number;

  @IsOptional()
  @IsString()
  fcmToken?: string;
}
