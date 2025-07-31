#!/bin/bash

echo "Corrigindo permissões para o Docker..."

# Define o usuário e grupo do Docker (geralmente 1000:1000)
DOCKER_USER_ID=${DOCKER_USER_ID:-1000}
DOCKER_GROUP_ID=${DOCKER_GROUP_ID:-1000}

# Cria o grupo se não existir
if ! getent group $DOCKER_GROUP_ID > /dev/null 2>&1; then
    echo "Criando grupo com ID $DOCKER_GROUP_ID..."
    sudo groupadd -g $DOCKER_GROUP_ID dockeruser
fi

# Cria o usuário se não existir
if ! getent passwd $DOCKER_USER_ID > /dev/null 2>&1; then
    echo "Criando usuário com ID $DOCKER_USER_ID..."
    sudo useradd -u $DOCKER_USER_ID -g $DOCKER_GROUP_ID -m dockeruser
fi

# Corrige permissões dos diretórios do Laravel
echo "Corrigindo permissões dos diretórios..."

# Cria diretórios necessários se não existirem
mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p bootstrap/cache

# Define permissões corretas
sudo chown -R $DOCKER_USER_ID:$DOCKER_GROUP_ID .
sudo chmod -R 775 storage
sudo chmod -R 775 bootstrap/cache
sudo chmod -R 775 vendor 2>/dev/null || true
sudo chmod -R 775 node_modules 2>/dev/null || true

# Garante que o arquivo .env pode ser criado
sudo chmod 775 .
sudo chown $DOCKER_USER_ID:$DOCKER_GROUP_ID .

echo "Permissões corrigidas com sucesso!"
echo "Agora você pode executar: docker-compose up --build" 