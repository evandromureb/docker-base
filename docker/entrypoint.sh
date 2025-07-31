#!/bin/bash
set -e

echo "Executando entrypoint como usuário: $(whoami)"
echo "Diretório atual: $(pwd)"

# Verificar se as dependências do Composer estão instaladas (PRIMEIRO!)
if [ ! -d "/var/www/vendor" ] || [ ! -f "/var/www/vendor/autoload.php" ]; then
    echo "Instalando dependências do Composer..."
    composer install --no-dev --optimize-autoloader --no-interaction
    echo "Dependências do Composer instaladas com sucesso!"
    
    # Configurar permissões do vendor após instalação
    chown -R root:root /var/www/vendor
    chmod -R 755 /var/www/vendor
    echo "Permissões do vendor configuradas!"
fi

# Verificar novamente se o vendor existe antes de continuar
if [ ! -f "/var/www/vendor/autoload.php" ]; then
    echo "ERRO: vendor/autoload.php não encontrado após instalação!"
    echo "Tentando instalar novamente..."
    composer install --no-dev --optimize-autoloader --no-interaction
    if [ ! -f "/var/www/vendor/autoload.php" ]; then
        echo "ERRO CRÍTICO: Não foi possível instalar as dependências do Composer!"
        exit 1
    fi
fi

echo "Configurando permissões do Laravel..."

echo "Corrigindo permissões do diretório raiz..."
chown -R root:root /var/www/
chmod -R 755 /var/www/

mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/cache
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/bootstrap/cache

touch /var/www/storage/logs/laravel.log

chmod -R 755 /var/www/storage/
chmod -R 755 /var/www/bootstrap/cache/

chown -R root:root /var/www/storage/
chown -R root:root /var/www/bootstrap/cache/

echo "Permissões configuradas com sucesso!"

if [ ! -f .env ]; then
    echo "Copiando .env.example para .env..."
    chmod 755 .
    chown root:root .
    cp .env.example .env
fi

if [ -f .env ]; then
    echo "Verificando configurações de cache..."
    if ! grep -q '^CACHE_STORE=file' .env; then
        echo "Configurando CACHE_STORE=file temporariamente..."
        sed -i 's/^CACHE_STORE=.*/CACHE_STORE=file/' .env
    fi
fi

if ! grep -q '^APP_KEY=.\+' .env; then
    echo "Gerando APP_KEY..."
    php artisan key:generate
fi

if [ -f package.json ]; then
    echo "Verificando dependências Node.js..."
    
    if [ ! -d node_modules ] || [ ! -f node_modules/.package-lock.json ]; then
        echo "Instalando dependências Node.js..."
        npm install
        echo "Dependências Node.js instaladas com sucesso!"
    else
        echo "node_modules já existe. Pulando instalação."
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

chmod -R 755 /var/www/storage/framework/cache/
chown -R root:root /var/www/storage/framework/cache/
mkdir -p /var/www/storage/framework/cache/data
chmod -R 755 /var/www/storage/framework/cache/data/
chown -R root:root /var/www/storage/framework/cache/data/

export CACHE_STORE=file

php artisan config:clear
php artisan view:clear
php artisan route:clear

if ! php artisan cache:clear; then
    echo "Aviso: Não foi possível limpar o cache. Continuando..."
    rm -rf /var/www/storage/framework/cache/*
    echo "Cache limpo manualmente."
fi

export CACHE_STORE=database

echo "Aplicação pronta!"
exec "$@"
