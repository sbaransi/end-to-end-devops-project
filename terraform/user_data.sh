#!/bin/bash
# Runs once, as root, on the first boot of the "builder" instance (Amazon Linux 2023).
# Installs Docker, Docker Compose and Git. Log: /var/log/user-data.log
set -euxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

# 1. Update the package manager
dnf update -y

# 2. Install Docker and Git, start Docker now and on every boot
dnf install -y docker git
systemctl enable --now docker

# 3. Install Docker Compose (v2 plugin, used as "docker compose")
COMPOSE_VERSION="v2.29.7"
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# 4. Let ec2-user run docker without sudo
usermod -aG docker ec2-user

# 5. Verify
docker --version
docker compose version
echo "user-data finished: Docker and Docker Compose are installed"
