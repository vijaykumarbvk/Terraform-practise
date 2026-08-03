#!/bin/bash
# Install Docker and Docker Compose
apt-get update -y
apt-get install -y docker.io
curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl start docker
systemctl enable docker

# Set up monitoring directory
mkdir -p /opt/monitoring
cd /opt/monitoring

# Create Prometheus configuration file
# The ${app_server_ip} variable is dynamically replaced by Terraform
cat << 'EOF' > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'monitoring_server'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'app_server'
    static_configs:
      - targets: ['${app_server_ip}:9100']
EOF

# Create Docker Compose file
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    restart: unless-stopped

  node_exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
EOF

# Start the stack
/usr/local/bin/docker-compose up -d