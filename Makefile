# =============================================================================
# Makefile para Projeto Laravel com Docker
# =============================================================================

# Variáveis
COMPOSE = docker compose
PHP_SERVICE = php
NGINX_SERVICE = nginx
MYSQL_SERVICE = mysql
REDIS_SERVICE = redis
MAILPIT_SERVICE = mailpit

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
WHITE = \033[0;37m
NC = \033[0m # No Color

# =============================================================================
# COMANDOS PRINCIPAIS
# =============================================================================

.PHONY: help
help: ## Mostra esta ajuda
	@echo "$(CYAN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# =============================================================================
# DOCKER COMPOSE
# =============================================================================

.PHONY: up
up: ## Inicia os containers em background
	@echo "$(BLUE)Iniciando containers...$(NC)"
	$(COMPOSE) up -d
	sleep 5
	@echo "$(GREEN)Aguardando para geração das migrations!$(NC)"
	@while ! $(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:status; do \
		echo "$(YELLOW)Aguardando migrações...$(NC)"; \
		sleep 5; \
	done
	$(MAKE) migrate
	$(COMPOSE) exec $(PHP_SERVICE) git config --global --add safe.directory /var/www
	@echo "$(BLUE)Atualizando dependências do Composer...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer update
	@echo "$(BLUE)Instalando dependências do NPM...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm install
	$(MAKE) permission

.PHONY: upb
upb: ## Inicia os containers com rebuild
	@echo "$(BLUE)Iniciando containers com rebuild...$(NC)"
	$(COMPOSE) up -d --build
	$(MAKE) permission

.PHONY: down
down: ## Para os containers
	@echo "$(YELLOW)Parando containers...$(NC)"
	$(COMPOSE) down

.PHONY: downv
downv: ## Para os containers e remove volumes
	@echo "$(RED)Parando containers e removendo volumes...$(NC)"
	$(COMPOSE) down -v

.PHONY: restart
restart: ## Reinicia os containers
	@echo "$(BLUE)Reiniciando containers...$(NC)"
	$(COMPOSE) restart

.PHONY: restartv
restartv: ## Reinicia os containers com rebuild e limpeza
	@echo "$(PURPLE)Reiniciando containers com rebuild...$(NC)"
	$(COMPOSE) down -v
	$(COMPOSE) up -d --build

.PHONY: build
build: ## Constrói as imagens
	@echo "$(BLUE)Construindo imagens...$(NC)"
	$(COMPOSE) build

.PHONY: logs
logs: ## Mostra logs dos containers
	$(COMPOSE) logs -f

.PHONY: logs-php
logs-php: ## Mostra logs do container PHP
	$(COMPOSE) logs -f $(PHP_SERVICE)

.PHONY: logs-nginx
logs-nginx: ## Mostra logs do container Nginx
	$(COMPOSE) logs -f $(NGINX_SERVICE)

.PHONY: logs-mysql
logs-mysql: ## Mostra logs do container MySQL
	$(COMPOSE) logs -f $(MYSQL_SERVICE)

# =============================================================================
# DESENVOLVIMENTO
# =============================================================================

.PHONY: bash
bash: ## Acessa o bash do container PHP
	$(COMPOSE) exec $(PHP_SERVICE) bash

.PHONY: shell
shell: ## Acessa o shell do Laravel (Tinker)
	$(COMPOSE) exec $(PHP_SERVICE) php artisan tinker

.PHONY: artisan
artisan: ## Executa comando artisan (uso: make artisan cmd="migrate")
	$(COMPOSE) exec $(PHP_SERVICE) php artisan $(cmd)

# =============================================================================
# COMPOSER
# =============================================================================

.PHONY: composer-install
composer-install: ## Instala dependências do Composer
	@echo "$(BLUE)Instalando dependências do Composer...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer install

.PHONY: composer-update
composer-update: ## Atualiza dependências do Composer
	@echo "$(BLUE)Atualizando dependências do Composer...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer update

.PHONY: composer-dump
composer-dump: ## Gera autoload do Composer
	$(COMPOSE) exec $(PHP_SERVICE) composer dump-autoload

.PHONY: composer-require
composer-require: ## Adiciona pacote via Composer (uso: make composer-require pkg="package/name")
	$(COMPOSE) exec $(PHP_SERVICE) composer require $(pkg)

# =============================================================================
# NPM/NODE
# =============================================================================

.PHONY: npm-install
npm-install: ## Instala dependências do NPM
	@echo "$(BLUE)Instalando dependências do NPM...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm install

.PHONY: npm-dev
npm-dev: ## Executa npm run dev
	$(COMPOSE) exec $(PHP_SERVICE) npm run dev

.PHONY: npm-build
npm-build: ## Executa npm run build
	$(COMPOSE) exec $(PHP_SERVICE) npm run build

.PHONY: npm-watch
npm-watch: ## Executa npm run watch
	$(COMPOSE) exec $(PHP_SERVICE) npm run watch

# =============================================================================
# LARAVEL - BANCO DE DADOS
# =============================================================================

.PHONY: migrate
migrate: ## Executa as migrações
	@echo "$(GREEN)Executando migrações...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate

.PHONY: migrate-fresh
migrate-fresh: ## Executa migrate:fresh --seed
	@echo "$(YELLOW)Executando migrate:fresh --seed...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:fresh --seed

.PHONY: migrate-rollback
migrate-rollback: ## Reverte a última migração
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:rollback

.PHONY: migrate-status
migrate-status: ## Mostra status das migrações
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:status

.PHONY: seed
seed: ## Executa os seeders
	@echo "$(GREEN)Executando seeders...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan db:seed

.PHONY: seed-class
seed-class: ## Executa seeder específico (uso: make seed-class class="UserSeeder")
	$(COMPOSE) exec $(PHP_SERVICE) php artisan db:seed --class=$(class)

# =============================================================================
# LARAVEL - CACHE E CONFIGURAÇÃO
# =============================================================================

.PHONY: cache-clear
cache-clear: ## Limpa todos os caches
	@echo "$(YELLOW)Limpando caches...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan cache:clear
	$(COMPOSE) exec $(PHP_SERVICE) php artisan config:clear
	$(COMPOSE) exec $(PHP_SERVICE) php artisan route:clear
	$(COMPOSE) exec $(PHP_SERVICE) php artisan view:clear

.PHONY: config-cache
config-cache: ## Cache das configurações
	$(COMPOSE) exec $(PHP_SERVICE) php artisan config:cache

.PHONY: route-cache
route-cache: ## Cache das rotas
	$(COMPOSE) exec $(PHP_SERVICE) php artisan route:cache

.PHONY: view-cache
view-cache: ## Cache das views
	$(COMPOSE) exec $(PHP_SERVICE) php artisan view:cache

.PHONY: optimize
optimize: ## Otimiza a aplicação para produção
	$(COMPOSE) exec $(PHP_SERVICE) php artisan optimize

# =============================================================================
# LARAVEL - DESENVOLVIMENTO
# =============================================================================

.PHONY: key-generate
key-generate: ## Gera chave da aplicação
	$(COMPOSE) exec $(PHP_SERVICE) php artisan key:generate

.PHONY: storage-link
storage-link: ## Cria link simbólico do storage
	$(COMPOSE) exec $(PHP_SERVICE) php artisan storage:link

.PHONY: make-controller
make-controller: ## Cria controller (uso: make make-controller name="UserController")
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:controller $(name)

.PHONY: make-model
make-model: ## Cria model (uso: make make-model name="User")
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:model $(name)

.PHONY: make-migration
make-migration: ## Cria migration (uso: make make-migration name="create_users_table")
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:migration $(name)

.PHONY: make-seeder
make-seeder: ## Cria seeder (uso: make make-seeder name="UserSeeder")
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:seeder $(name)

# =============================================================================
# TESTES
# =============================================================================

.PHONY: test
test: ## Executa os testes
	@echo "$(GREEN)Executando testes...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan test

.PHONY: test-coverage
test-coverage: ## Executa testes com cobertura
	$(COMPOSE) exec $(PHP_SERVICE) php artisan test --coverage

.PHONY: test-pest
test-pest: ## Executa testes Pest
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/pest

# =============================================================================
# QUALIDADE DE CÓDIGO
# =============================================================================

.PHONY: pint
pint: ## Executa Laravel Pint (formatação de código)
	@echo "$(BLUE)Formatando código com Pint...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/pint

.PHONY: pint-check
pint-check: ## Verifica formatação sem alterar
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/pint --test

.PHONY: phpstan
phpstan: ## Executa PHPStan (análise estática)
	@echo "$(BLUE)Executando análise estática...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/phpstan analyse

.PHONY: rector
rector: ## Executa Rector (refatoração automática)
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/rector process

# =============================================================================
# SISTEMA
# =============================================================================

.PHONY: permission
permission: ## Ajusta permissões dos arquivos
	@echo "$(YELLOW)Ajustando permissões...$(NC)"
	sudo chmod -R 777 ./

.PHONY: clean
clean: ## Limpa arquivos temporários
	@echo "$(YELLOW)Limpando arquivos temporários...$(NC)"
	find . -name "*.log" -delete
	find . -name "*.tmp" -delete
	find . -name ".DS_Store" -delete

.PHONY: status
status: ## Mostra status dos containers
	@echo "$(CYAN)Status dos containers:$(NC)"
	$(COMPOSE) ps

.PHONY: top
top: ## Mostra uso de recursos dos containers
	$(COMPOSE) top

# =============================================================================
# DESENVOLVIMENTO RÁPIDO
# =============================================================================

.PHONY: dev-setup
dev-setup: ## Configuração inicial para desenvolvimento
	@echo "$(GREEN)Configurando ambiente de desenvolvimento...$(NC)"
	$(MAKE) downv
	$(MAKE) upb
	$(MAKE) permission
	$(COMPOSE) exec $(PHP_SERVICE) git config --global --add safe.directory /var/www
	$(MAKE) composer-install
	$(MAKE) key-generate
	$(MAKE) storage-link

	sleep 10
	@echo "$(GREEN)Aguardando para geração das migrations!$(NC)"
	@while ! $(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:status; do \
		echo "$(YELLOW)Aguardando migrações...$(NC)"; \
		sleep 5; \
	done
	$(MAKE) migrate-fresh
	$(MAKE) permission
	$(MAKE) npm-install
	$(COMPOSE) exec $(PHP_SERVICE) npm audit fix
	$(MAKE) permission
	@echo "$(GREEN)Ambiente configurado com sucesso!$(NC)"

.PHONY: dev-reset
dev-reset: ## Reset completo do ambiente de desenvolvimento
	@echo "$(RED)Resetando ambiente de desenvolvimento...$(NC)"
	$(MAKE) downv
	$(MAKE) clean
	$(MAKE) dev-setup

.PHONY: quick-test
quick-test: ## Teste rápido do ambiente
	@echo "$(CYAN)Testando ambiente...$(NC)"
	$(MAKE) status
	@echo "$(GREEN)Teste concluído!$(NC)"
