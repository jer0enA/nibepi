# ---- Build stage: compiles serialport's native binding ----
FROM node:22-alpine AS build
RUN apk add --no-cache python3 make g++
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .

# ---- Runtime stage: no compiler, no build deps, non-root user ----
FROM node:22-alpine
WORKDIR /app
RUN mkdir -p /etc/nibepi && chown -R node:node /etc/nibepi
COPY --from=build --chown=node:node /app ./
USER node
EXPOSE 1880
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:1880/ >/dev/null 2>&1 || exit 1
CMD ["node", "bridge.js"]
