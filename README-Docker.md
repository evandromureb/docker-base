# Docker Setup para Laravel com Node.js

Este projeto está configurado para rodar Laravel com Node.js usando Docker.

## Funcionalidades

- **PHP 8.4** com FPM
- **Node.js 18.x** para assets frontend
- **MySQL 8** como banco de dados
- **Nginx** como servidor web
- **Redis** para cache
- **Mailpit** para captura de emails em desenvolvimento

## Instalação Automática de Dependências

O container está configurado para executar automaticamente:

1. **Composer install** - Dependências PHP
2. **npm install** - Dependências Node.js
3. **npm run build** - Build do Vite (apenas em produção)

### Como funciona

Quando o container é iniciado, o `entrypoint.sh` executa automaticamente:

```bash
# Instala dependências Node.js (se package.json existir)
# Verifica se node_modules já existe e se package.json foi modificado
# Executa npm install apenas quando necessário
# Em produção, também executa npm run build

# Limpa caches do Laravel
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
```

### Comportamento do npm install

O entrypoint verifica:

- Se `package.json` existe
- Se `node_modules` já existe e `package.json` não foi modificado
- Executa `npm install` apenas quando necessário
- Em produção, também executa `npm run build`

## Como usar

### Desenvolvimento

```bash
# Construir e iniciar containers
docker-compose up --build

# Ou em background
docker-compose up -d --build
```

### Produção

```bash
# Definir ambiente de produção
export APP_ENV=production

# Construir e iniciar
docker-compose up --build
```

## Estrutura dos Containers

- **php**: Container principal com PHP 8.4 + Node.js 18
- **nginx**: Servidor web
- **mysql**: Banco de dados
- **redis**: Cache
- **mailpit**: Captura de emails

## Volumes

- `./:/var/www` - Código da aplicação
- `storage_data:/var/www/storage` - Dados persistentes do Laravel
- `db_data:/var/lib/mysql` - Dados do MySQL

## Portas

- **8080**: Aplicação Laravel
- **5173**: Vite dev server
- **80**: Nginx
- **3306**: MySQL
- **6379**: Redis
- **8025**: Mailpit

## Desenvolvimento Frontend

Para desenvolvimento frontend com hot reload:

```bash
# Acessar o container
docker-compose exec php bash

# Executar Vite em modo desenvolvimento
npm run dev
```

## Logs

```bash
# Ver logs de todos os containers
docker-compose logs

# Ver logs de um container específico
docker-compose logs php
docker-compose logs nginx
```

## Troubleshooting

### Problemas com permissões

```bash
# Corrigir permissões
docker-compose exec php chown -R appuser:appuser /var/www
```

### Reinstalar dependências

```bash
# Reinstalar dependências PHP
docker-compose exec php composer install

# Reinstalar dependências Node.js
docker-compose exec php npm install
```

### Limpar caches

```bash
# Limpar caches do Laravel
docker-compose exec php php artisan config:clear
docker-compose exec php php artisan cache:clear
docker-compose exec php php artisan view:clear
docker-compose exec php php artisan route:clear
``` 