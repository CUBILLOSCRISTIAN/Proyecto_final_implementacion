# Etapa 1: Build
FROM node:20-bullseye AS builder

# Crea el directorio de trabajo
WORKDIR /app

# Copia los archivos de dependencias primero
COPY package*.json ./

# Instala las dependencias
RUN npm install

# Copia el resto del proyecto
COPY . .

# Construye el proyecto (si estás usando TypeScript y NestJS)
RUN npm run build

# Expón el puerto que usa tu servicio
EXPOSE 3011

# Comando para ejecutar la app compilada
CMD ["node", "dist/main"]
