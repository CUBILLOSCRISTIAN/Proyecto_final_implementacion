import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

@Schema()
export class User extends Document {
    @Prop({ required: true, unique: true })
    deviceId: string;

    @Prop()
    fcmToken?: string;

    @Prop({ required: true })
    limiteDiario: number;

    @Prop({ required: true })
    limiteMensual: number;

    @Prop({ default: true })
    notificacionesActivas: boolean;

    @Prop({ default: Date.now })
    fechaRegistro: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);
