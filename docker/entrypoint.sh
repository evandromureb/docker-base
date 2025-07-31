#!/bin/bash
set -e

echo "Executando composer install em $(pwd)"
ls -la

# Atualiza o Composer para a versão mais recente
composer self-update

# Executa composer install
composer install --no-interaction --prefer-dist

# Instala dependências Node.js
if [ -f package.json ]; then
  npm install
fi

# Copia .env.example para .env se não existir
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Gera APP_KEY se não existir
if ! grep -q '^APP_KEY=.\+' .env; then
    php artisan key:generate
fi



# Permissões para storage e bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache

# (Opcional) Se precisar rodar npm como www-data, ajuste node_modules, mas evite 777
# chown -R www-data:www-data node_modules
# chmod -R ug+rwX node_modules

# Verifica se o banco de dados está acessível
until php artisan migrate --force; do
    echo "Aguardando o banco de dados..."
    sleep 10
done

exec "$@"
