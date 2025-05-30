# Etapa 1: Build
FROM node:20-bullseye AS builder

WORKDIR /app

COPY package*.json ./
COPY . .
RUN npm install
RUN npm run build

# Etapa 2: Run
FROM node:20-bullseye-slim

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

RUN npm install --only=production

EXPOSE 3013

CMD ["node", "dist/main"]