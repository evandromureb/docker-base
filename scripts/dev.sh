#!/bin/bash

# Script para executar o Vite dentro do container Docker
echo "Iniciando servidor de desenvolvimento..."

# Verifica se o container está rodando
if ! docker-compose ps | grep -q "php.*Up"; then
    echo "Iniciando containers..."
    docker-compose up -d
fi

# Executa o Vite dentro do container
echo "Executando Vite no container..."
docker-compose exec php npm run dev 