#!/bin/bash
set -e

echo "Executando entrypoint como usuário: $(whoami)"
echo "Diretório atual: $(pwd)"

echo "Configurando permissões do Laravel..."

echo "Corrigindo permissões do diretório raiz..."
chown -R appuser:appuser /var/www/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/
chmod -R 775 /var/www/ 2>/dev/null || sudo chmod -R 775 /var/www/

mkdir -p /var/www/storage/logs || sudo mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/cache || sudo mkdir -p /var/www/storage/framework/cache
mkdir -p /var/www/storage/framework/sessions || sudo mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views || sudo mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/bootstrap/cache || sudo mkdir -p /var/www/bootstrap/cache

touch /var/www/storage/logs/laravel.log 2>/dev/null || sudo touch /var/www/storage/logs/laravel.log

chmod -R 775 /var/www/storage/ 2>/dev/null || sudo chmod -R 775 /var/www/storage/
chmod -R 775 /var/www/bootstrap/cache/ 2>/dev/null || sudo chmod -R 775 /var/www/bootstrap/cache/

chown -R appuser:appuser /var/www/storage/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/storage/
chown -R appuser:appuser /var/www/bootstrap/cache/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/bootstrap/cache/

echo "Permissões configuradas com sucesso!"

if [ ! -f .env ]; then
    echo "Copiando .env.example para .env..."
    # Garante que temos permissão para escrever no diretório atual
    chmod 775 . 2>/dev/null || sudo chmod 775 .
    chown appuser:appuser . 2>/dev/null || sudo chown appuser:appuser .
    cp .env.example .env
fi

if [ -f .env ]; then
    echo "Verificando configurações de cache..."
    if ! grep -q '^CACHE_STORE=file' .env; then
        echo "Configurando CACHE_STORE=file temporariamente..."
        sed -i 's/^CACHE_STORE=.*/CACHE_STORE=file/' .env 2>/dev/null || true
    fi
fi

if ! grep -q '^APP_KEY=.\+' .env; then
    echo "Gerando APP_KEY..."
    php artisan key:generate
fi

if [ -f package.json ]; then
    echo "Verificando dependências Node.js..."
    
    if [ -d node_modules ] && [ package.json -ot node_modules ]; then
        echo "node_modules já existe e package.json não foi modificado. Pulando instalação."
    else
        echo "Instalando dependências Node.js..."
        npm install
        echo "Dependências Node.js instaladas com sucesso!"
    fi
    
    if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "prod" ]; then
        echo "Executando build do Vite para produção..."
        npm run build
        echo "Build do Vite concluído!"
    fi
else
    echo "package.json não encontrado. Pulando instalação de dependências Node.js."
fi

echo "Verificando conexão com banco de dados..."
until php artisan migrate --force; do
    echo "Aguardando o banco de dados..."
    sleep 10
done

echo "Limpando caches..."

chmod -R 775 /var/www/storage/framework/cache/ 2>/dev/null || sudo chmod -R 775 /var/www/storage/framework/cache/
chown -R appuser:appuser /var/www/storage/framework/cache/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/storage/framework/cache/
mkdir -p /var/www/storage/framework/cache/data 2>/dev/null || sudo mkdir -p /var/www/storage/framework/cache/data
chmod -R 775 /var/www/storage/framework/cache/data/ 2>/dev/null || sudo chmod -R 775 /var/www/storage/framework/cache/data/
chown -R appuser:appuser /var/www/storage/framework/cache/data/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/storage/framework/cache/data/


export CACHE_STORE=file

php artisan config:clear
php artisan view:clear
php artisan route:clear

if ! php artisan cache:clear; then
    echo "Aviso: Não foi possível limpar o cache. Continuando..."
    rm -rf /var/www/storage/framework/cache/* 2>/dev/null || sudo rm -rf /var/www/storage/framework/cache/*
    echo "Cache limpo manualmente."
fi

export CACHE_STORE=database

echo "Aplicação pronta!"
exec "$@"
