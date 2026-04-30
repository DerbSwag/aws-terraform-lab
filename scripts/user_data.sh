#!/bin/bash
set -euo pipefail

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

# Install Docker Compose
apt-get install -y docker-compose-plugin

# Create app directory
mkdir -p /opt/app
cat > /opt/app/docker-compose.yml <<'EOF'
services:
  fastapi:
    image: ghcr.io/derbswag/devops-fastapi-lab:latest
    ports:
      - "${app_port}:8000"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - fastapi
    restart: unless-stopped
EOF

cat > /opt/app/nginx.conf <<'EOF'
server {
    listen 80;
    location / {
        proxy_pass http://fastapi:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Start app
cd /opt/app
docker compose up -d
