#!/bin/bash
set -e

echo "Executando entrypoint como usuário: $(whoami)"
echo "Diretório atual: $(pwd)"

# Configura permissões corretas para Laravel
echo "Configurando permissões do Laravel..."

# Cria diretórios necessários
mkdir -p /var/www/storage/logs || sudo mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/cache || sudo mkdir -p /var/www/storage/framework/cache
mkdir -p /var/www/storage/framework/sessions || sudo mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views || sudo mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/bootstrap/cache || sudo mkdir -p /var/www/bootstrap/cache

# Cria arquivo de log se não existir
touch /var/www/storage/logs/laravel.log 2>/dev/null || sudo touch /var/www/storage/logs/laravel.log

# Define permissões corretas
chmod -R 775 /var/www/storage/ 2>/dev/null || sudo chmod -R 775 /var/www/storage/
chmod -R 775 /var/www/bootstrap/cache/ 2>/dev/null || sudo chmod -R 775 /var/www/bootstrap/cache/

# Define proprietário correto
chown -R appuser:appuser /var/www/storage/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/storage/
chown -R appuser:appuser /var/www/bootstrap/cache/ 2>/dev/null || sudo chown -R appuser:appuser /var/www/bootstrap/cache/

echo "Permissões configuradas com sucesso!"

# Copia .env.example para .env se não existir
if [ ! -f .env ]; then
    echo "Copiando .env.example para .env..."
    cp .env.example .env
fi

# Gera APP_KEY se não existir
if ! grep -q '^APP_KEY=.\+' .env; then
    echo "Gerando APP_KEY..."
    php artisan key:generate
fi

# Instala dependências Node.js se package.json existir
if [ -f package.json ]; then
    echo "Verificando dependências Node.js..."
    
    # Verifica se node_modules existe e se package.json foi modificado
    if [ -d node_modules ] && [ package.json -ot node_modules ]; then
        echo "node_modules já existe e package.json não foi modificado. Pulando instalação."
    else
        echo "Instalando dependências Node.js..."
        npm install
        echo "Dependências Node.js instaladas com sucesso!"
    fi
    
    # Executa build do Vite se estiver em produção
    if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "prod" ]; then
        echo "Executando build do Vite para produção..."
        npm run build
        echo "Build do Vite concluído!"
    fi
else
    echo "package.json não encontrado. Pulando instalação de dependências Node.js."
fi

# Verifica se o banco de dados está acessível e executa migrations
echo "Verificando conexão com banco de dados..."
until php artisan migrate --force; do
    echo "Aguardando o banco de dados..."
    sleep 10
done

# Limpa caches do Laravel (após migrations)
echo "Limpando caches..."

# Temporariamente muda o driver de cache para file para evitar erros
export CACHE_STORE=file

php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan cache:clear

# Restaura o driver de cache original
export CACHE_STORE=database

echo "Aplicação pronta!"
exec "$@"
