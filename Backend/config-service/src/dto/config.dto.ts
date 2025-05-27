import { IsString, IsOptional, IsInt, IsNumber } from 'class-validator';

export class ConfigDto {
  @IsString()
  deviceId: string;

  @IsOptional()
  @IsString()
  wifiSSID?: string;

  @IsOptional()
  @IsString()
  wifiPassword?: string;

  @IsOptional()
  @IsString()
  mqttHost?: string;

  @IsOptional()
  @IsInt()
  mqttPort?: number;

  @IsOptional()
  @IsNumber()
  calibrationFactor?: number;
}
