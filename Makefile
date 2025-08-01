# =============================================================================
# Makefile para Projeto Laravel com Docker
# Versão: 2.0
# =============================================================================

# Variáveis
COMPOSE = docker compose
PHP_SERVICE = php
NGINX_SERVICE = nginx
MYSQL_SERVICE = mysql
REDIS_SERVICE = redis
MAILPIT_SERVICE = mailpit

# Configurações do projeto
PROJECT_NAME = laravel-app
PHP_VERSION = 8.2
NODE_VERSION = 18

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
WHITE = \033[0;37m
BOLD = \033[1m
NC = \033[0m # No Color

# =============================================================================
# VALIDAÇÕES
# =============================================================================

.PHONY: check-docker
check-docker: ## Verifica se Docker está instalado e rodando
	@docker --version > /dev/null 2>&1 || (echo "$(RED)❌ Docker não está instalado$(NC)" && exit 1)
	@docker info > /dev/null 2>&1 || (echo "$(RED)❌ Docker não está rodando$(NC)" && exit 1)
	@echo "$(GREEN)✅ Docker está funcionando$(NC)"

.PHONY: check-compose
check-compose: ## Verifica se Docker Compose está disponível
	@docker compose version > /dev/null 2>&1 || (echo "$(RED)❌ Docker Compose não está disponível$(NC)" && exit 1)
	@echo "$(GREEN)✅ Docker Compose está disponível$(NC)"

# =============================================================================
# COMANDOS PRINCIPAIS
# =============================================================================

.PHONY: help
help: ## Mostra esta ajuda
	@echo "$(BOLD)$(CYAN)========================================$(NC)"
	@echo "$(BOLD)$(CYAN)  Makefile Laravel + Docker$(NC)"
	@echo "$(BOLD)$(CYAN)========================================$(NC)"
	@echo ""
	@echo "$(CYAN)Comandos disponíveis:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Exemplos de uso:$(NC)"
	@echo "  make artisan cmd=\"migrate\""
	@echo "  make composer-require pkg=\"laravel/sanctum\""
	@echo "  make make-controller name=\"UserController\""
	@echo "  make seed-class class=\"UserSeeder\""

.PHONY: info
info: ## Mostra informações do projeto
	@echo "$(BOLD)$(CYAN)Informações do Projeto:$(NC)"
	@echo "$(WHITE)Projeto:$(NC) $(PROJECT_NAME)"
	@echo "$(WHITE)PHP:$(NC) $(PHP_VERSION)"
	@echo "$(WHITE)Node:$(NC) $(NODE_VERSION)"
	@echo "$(WHITE)Serviços:$(NC) PHP, Nginx, MySQL, Redis, Mailpit"

# =============================================================================
# DOCKER COMPOSE
# =============================================================================

.PHONY: up
up: check-docker check-compose ## Inicia os containers em background
	@echo "$(BLUE)🚀 Iniciando containers...$(NC)"
	$(COMPOSE) down
	$(COMPOSE) up -d
	docker compose exec php git config --global --add safe.directory /var/www
	$(MAKE) npm-install
	$(MAKE) composer-update
	$(MAKE) migrate
	$(MAKE) cache-clear
	$(MAKE) config-all
	$(MAKE) permission
	@echo "$(GREEN)✅ Ambiente iniciado com sucesso!$(NC)"

.PHONY: upb
upb: check-docker check-compose ## Inicia os containers com rebuild
	@echo "$(BLUE)🔨 Iniciando containers com rebuild...$(NC)"
	$(COMPOSE) down
	$(COMPOSE) up -d --build
	docker compose exec php git config --global --add safe.directory /var/www
	$(MAKE) npm-install
	$(MAKE) composer-update
	$(MAKE) migrate
	$(MAKE) cache-clear
	$(MAKE) config-all
	$(MAKE) permission
	@echo "$(GREEN)✅ Ambiente iniciado com rebuild!$(NC)"

.PHONY: down
down: ## Para os containers
	@echo "$(YELLOW)🛑 Parando containers...$(NC)"
	$(COMPOSE) down
	@echo "$(GREEN)✅ Containers parados$(NC)"

.PHONY: downv
downv: ## Para os containers e remove volumes
	@echo "$(RED)🗑️ Parando containers e removendo volumes...$(NC)"
	$(COMPOSE) down -v
	@echo "$(GREEN)✅ Containers parados e volumes removidos$(NC)"

.PHONY: restart
restart: ## Reinicia os containers
	@echo "$(BLUE)🔄 Reiniciando containers...$(NC)"
	$(COMPOSE) restart
	@echo "$(GREEN)✅ Containers reiniciados$(NC)"

.PHONY: restartv
restartv: ## Reinicia os containers com rebuild e limpeza
	@echo "$(PURPLE)🔄 Reiniciando containers com rebuild...$(NC)"
	$(COMPOSE) down -v
	$(COMPOSE) up -d --build
	@echo "$(GREEN)✅ Containers reiniciados com rebuild$(NC)"

.PHONY: build
build: ## Constrói as imagens
	@echo "$(BLUE)🔨 Construindo imagens...$(NC)"
	$(COMPOSE) build
	@echo "$(GREEN)✅ Imagens construídas$(NC)"

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

.PHONY: logs-redis
logs-redis: ## Mostra logs do container Redis
	$(COMPOSE) logs -f $(REDIS_SERVICE)

.PHONY: logs-mailpit
logs-mailpit: ## Mostra logs do container Mailpit
	$(COMPOSE) logs -f $(MAILPIT_SERVICE)

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
	@if [ -z "$(cmd)" ]; then \
		echo "$(RED)❌ Comando não especificado. Use: make artisan cmd=\"comando\"$(NC)"; \
		exit 1; \
	fi
	$(COMPOSE) exec $(PHP_SERVICE) php artisan $(cmd)

.PHONY: mysql
mysql: ## Acessa o MySQL
	$(COMPOSE) exec $(MYSQL_SERVICE) mysql -u root -p

.PHONY: redis-cli
redis-cli: ## Acessa o Redis CLI
	$(COMPOSE) exec $(REDIS_SERVICE) redis-cli

# =============================================================================
# COMPOSER
# =============================================================================

.PHONY: composer-install
composer-install: ## Instala dependências do Composer
	@echo "$(BLUE)📦 Instalando dependências do Composer...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer install
	@echo "$(GREEN)✅ Dependências do Composer instaladas$(NC)"

.PHONY: composer-update
composer-update: ## Atualiza dependências do Composer
	@echo "$(BLUE)🔄 Atualizando dependências do Composer...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer update
	@echo "$(GREEN)✅ Dependências do Composer atualizadas$(NC)"

.PHONY: composer-dump
composer-dump: ## Gera autoload do Composer
	@echo "$(BLUE)🔄 Gerando autoload...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer dump-autoload
	@echo "$(GREEN)✅ Autoload gerado$(NC)"

.PHONY: composer-require
composer-require: ## Adiciona pacote via Composer (uso: make composer-require pkg="package/name")
	@if [ -z "$(pkg)" ]; then \
		echo "$(RED)❌ Pacote não especificado. Use: make composer-require pkg=\"package/name\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📦 Instalando pacote $(pkg)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer require $(pkg)
	@echo "$(GREEN)✅ Pacote $(pkg) instalado$(NC)"

.PHONY: composer-remove
composer-remove: ## Remove pacote via Composer (uso: make composer-remove pkg="package/name")
	@if [ -z "$(pkg)" ]; then \
		echo "$(RED)❌ Pacote não especificado. Use: make composer-remove pkg=\"package/name\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🗑️ Removendo pacote $(pkg)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) composer remove $(pkg)
	@echo "$(GREEN)✅ Pacote $(pkg) removido$(NC)"

# =============================================================================
# NPM/NODE
# =============================================================================

.PHONY: npm-install
npm-install: ## Instala dependências do NPM
	@echo "$(BLUE)📦 Instalando dependências do NPM...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm install
	@echo "$(GREEN)✅ Dependências do NPM instaladas$(NC)"

.PHONY: npm-dev
npm-dev: ## Executa npm run dev
	@echo "$(BLUE)🔄 Executando npm run dev...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm run dev
	@echo "$(GREEN)✅ npm run dev concluído$(NC)"

.PHONY: npm-build
npm-build: ## Executa npm run build
	@echo "$(BLUE)🔨 Executando npm run build...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm run build
	@echo "$(GREEN)✅ npm run build concluído$(NC)"

.PHONY: npm-watch
npm-watch: ## Executa npm run watch
	@echo "$(BLUE)👀 Executando npm run watch...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm run watch

.PHONY: npm-audit
npm-audit: ## Executa auditoria de segurança do NPM
	@echo "$(BLUE)🔍 Executando auditoria de segurança...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm audit
	@echo "$(GREEN)✅ Auditoria concluída$(NC)"

.PHONY: npm-audit-fix
npm-audit-fix: ## Corrige vulnerabilidades do NPM
	@echo "$(BLUE)🔧 Corrigindo vulnerabilidades...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) npm audit fix
	@echo "$(GREEN)✅ Vulnerabilidades corrigidas$(NC)"

# =============================================================================
# LARAVEL - BANCO DE DADOS
# =============================================================================

.PHONY: migrate
migrate: ## Executa as migrações
	@echo "$(GREEN)🔄 Executando migrations...$(NC)"
	sleep 5
	@echo "$(GREEN)⏳ Aguardando para geração das migrations!$(NC)"
	@while ! $(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:status; do \
		echo "$(YELLOW)⏳ Aguardando migrações...$(NC)"; \
		sleep 5; \
	done
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate
	@echo "$(GREEN)✅ Migrações executadas$(NC)"

.PHONY: migrate-fresh
migrate-fresh: ## Executa migrate:fresh --seed
	@echo "$(YELLOW)⚠️ Executando migrate:fresh --seed...$(NC)"
	@echo "$(RED)⚠️ ATENÇÃO: Isso apagará todos os dados!$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:fresh --seed
	@echo "$(GREEN)✅ Migrações frescas executadas$(NC)"

.PHONY: migrate-rollback
migrate-rollback: ## Reverte a última migração
	@echo "$(YELLOW)🔄 Revertendo última migração...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:rollback
	@echo "$(GREEN)✅ Migração revertida$(NC)"

.PHONY: migrate-status
migrate-status: ## Mostra status das migrações
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:status

.PHONY: migrate-reset
migrate-reset: ## Reseta todas as migrações
	@echo "$(RED)⚠️ ATENÇÃO: Isso apagará todos os dados!$(NC)"
	@read -p "Tem certeza? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	$(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:reset
	@echo "$(GREEN)✅ Migrações resetadas$(NC)"

.PHONY: seed
seed: ## Executa os seeders
	@echo "$(GREEN)🌱 Executando seeders...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan db:seed
	@echo "$(GREEN)✅ Seeders executados$(NC)"

.PHONY: seed-class
seed-class: ## Executa seeder específico (uso: make seed-class class="UserSeeder")
	@if [ -z "$(class)" ]; then \
		echo "$(RED)❌ Classe não especificada. Use: make seed-class class=\"UserSeeder\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)🌱 Executando seeder $(class)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan db:seed --class=$(class)
	@echo "$(GREEN)✅ Seeder $(class) executado$(NC)"

# =============================================================================
# LARAVEL - CACHE E CONFIGURAÇÃO
# =============================================================================

.PHONY: cache-clear
cache-clear: ## Limpa todos os caches
	@echo "$(YELLOW)🧹 Limpando caches...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan cache:clear
	$(COMPOSE) exec $(PHP_SERVICE) php artisan config:clear
	$(COMPOSE) exec $(PHP_SERVICE) php artisan route:clear
	$(COMPOSE) exec $(PHP_SERVICE) php artisan view:clear
	@echo "$(GREEN)✅ Caches limpos$(NC)"

.PHONY: config-all
config-all: ## Cache das configurações
	@echo "$(BLUE)⚙️ Gerando caches de configuração...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan config:cache
	$(COMPOSE) exec $(PHP_SERVICE) php artisan route:cache
	$(COMPOSE) exec $(PHP_SERVICE) php artisan view:cache
	@echo "$(GREEN)✅ Caches de configuração gerados$(NC)"

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
	@echo "$(BLUE)🚀 Otimizando aplicação...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan optimize
	@echo "$(GREEN)✅ Aplicação otimizada$(NC)"

# =============================================================================
# LARAVEL - DESENVOLVIMENTO
# =============================================================================

.PHONY: key-generate
key-generate: ## Gera chave da aplicação
	@echo "$(BLUE)🔑 Gerando chave da aplicação...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan key:generate
	@echo "$(GREEN)✅ Chave gerada$(NC)"

.PHONY: storage-link
storage-link: ## Cria link simbólico do storage
	@echo "$(BLUE)🔗 Criando link simbólico do storage...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan storage:link
	@echo "$(GREEN)✅ Link simbólico criado$(NC)"

.PHONY: make-controller
make-controller: ## Cria controller (uso: make make-controller name="UserController")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)❌ Nome não especificado. Use: make make-controller name=\"UserController\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Criando controller $(name)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:controller $(name)
	@echo "$(GREEN)✅ Controller $(name) criado$(NC)"

.PHONY: make-model
make-model: ## Cria model (uso: make make-model name="User")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)❌ Nome não especificado. Use: make make-model name=\"User\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Criando model $(name)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:model $(name)
	@echo "$(GREEN)✅ Model $(name) criado$(NC)"

.PHONY: make-migration
make-migration: ## Cria migration (uso: make make-migration name="create_users_table")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)❌ Nome não especificado. Use: make make-migration name=\"create_users_table\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Criando migration $(name)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:migration $(name)
	@echo "$(GREEN)✅ Migration $(name) criada$(NC)"

.PHONY: make-seeder
make-seeder: ## Cria seeder (uso: make make-seeder name="UserSeeder")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)❌ Nome não especificado. Use: make make-seeder name=\"UserSeeder\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Criando seeder $(name)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:seeder $(name)
	@echo "$(GREEN)✅ Seeder $(name) criado$(NC)"

.PHONY: make-request
make-request: ## Cria request (uso: make make-request name="UserRequest")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)❌ Nome não especificado. Use: make make-request name=\"UserRequest\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Criando request $(name)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:request $(name)
	@echo "$(GREEN)✅ Request $(name) criado$(NC)"

.PHONY: make-resource
make-resource: ## Cria resource (uso: make make-resource name="UserResource")
	@if [ -z "$(name)" ]; then \
		echo "$(RED)❌ Nome não especificado. Use: make make-resource name=\"UserResource\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)📝 Criando resource $(name)...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan make:resource $(name)
	@echo "$(GREEN)✅ Resource $(name) criado$(NC)"

# =============================================================================
# TESTES
# =============================================================================

.PHONY: test
test: ## Executa os testes
	@echo "$(GREEN)🧪 Executando testes...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan test
	@echo "$(GREEN)✅ Testes concluídos$(NC)"

.PHONY: test-coverage
test-coverage: ## Executa testes com cobertura
	@echo "$(GREEN)🧪 Executando testes com cobertura...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan test --coverage
	@echo "$(GREEN)✅ Testes com cobertura concluídos$(NC)"

.PHONY: test-pest
test-pest: ## Executa testes Pest
	@echo "$(GREEN)🧪 Executando testes Pest...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/pest
	@echo "$(GREEN)✅ Testes Pest concluídos$(NC)"

.PHONY: test-parallel
test-parallel: ## Executa testes em paralelo
	@echo "$(GREEN)🧪 Executando testes em paralelo...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) php artisan test --parallel
	@echo "$(GREEN)✅ Testes paralelos concluídos$(NC)"

# =============================================================================
# QUALIDADE DE CÓDIGO
# =============================================================================

.PHONY: pint
pint: ## Executa Laravel Pint (formatação de código)
	@echo "$(BLUE)🎨 Formatando código com Pint...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/pint
	@echo "$(GREEN)✅ Código formatado$(NC)"

.PHONY: pint-check
pint-check: ## Verifica formatação sem alterar
	@echo "$(BLUE)🔍 Verificando formatação...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/pint --test
	@echo "$(GREEN)✅ Formatação verificada$(NC)"

.PHONY: phpstan
phpstan: ## Executa PHPStan (análise estática)
	@echo "$(BLUE)🔍 Executando análise estática...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/phpstan analyse
	@echo "$(GREEN)✅ Análise estática concluída$(NC)"

.PHONY: rector
rector: ## Executa Rector (refatoração automática)
	@echo "$(BLUE)🔧 Executando refatoração automática...$(NC)"
	$(COMPOSE) exec $(PHP_SERVICE) ./vendor/bin/rector process
	@echo "$(GREEN)✅ Refatoração concluída$(NC)"

.PHONY: quality
quality: ## Executa todas as ferramentas de qualidade
	@echo "$(BLUE)🔍 Executando análise de qualidade...$(NC)"
	$(MAKE) pint-check
	$(MAKE) phpstan
	@echo "$(GREEN)✅ Análise de qualidade concluída$(NC)"

# =============================================================================
# SISTEMA
# =============================================================================

.PHONY: permission
permission: ## Ajusta permissões dos arquivos
	@echo "$(YELLOW)🔧 Ajustando permissões...$(NC)"
	sudo chmod -R 777 ./
	@echo "$(GREEN)✅ Permissões ajustadas$(NC)"

.PHONY: clean
clean: ## Limpa arquivos temporários
	@echo "$(YELLOW)🧹 Limpando arquivos temporários...$(NC)"
	find . -name "*.log" -delete
	find . -name "*.tmp" -delete
	find . -name ".DS_Store" -delete
	find . -name "Thumbs.db" -delete
	@echo "$(GREEN)✅ Arquivos temporários limpos$(NC)"

.PHONY: status
status: ## Mostra status dos containers
	@echo "$(CYAN)📊 Status dos containers:$(NC)"
	$(COMPOSE) ps

.PHONY: top
top: ## Mostra uso de recursos dos containers
	$(COMPOSE) top

.PHONY: stats
stats: ## Mostra estatísticas dos containers
	@echo "$(CYAN)📈 Estatísticas dos containers:$(NC)"
	docker stats --no-stream

.PHONY: health
health: ## Verifica saúde dos serviços
	@echo "$(CYAN)🏥 Verificando saúde dos serviços...$(NC)"
	@echo "$(BLUE)PHP:$(NC)"
	@$(COMPOSE) exec $(PHP_SERVICE) php -v
	@echo "$(BLUE)MySQL:$(NC)"
	@$(COMPOSE) exec $(MYSQL_SERVICE) mysql --version
	@echo "$(BLUE)Redis:$(NC)"
	@$(COMPOSE) exec $(REDIS_SERVICE) redis-server --version
	@echo "$(GREEN)✅ Todos os serviços estão funcionando$(NC)"

# =============================================================================
# DESENVOLVIMENTO RÁPIDO
# =============================================================================

.PHONY: dev-setup
dev-setup: ## Configuração inicial para desenvolvimento
	$(MAKE) downv
	@echo "$(GREEN)🚀 Configurando ambiente de desenvolvimento...$(NC)"
	$(MAKE) upb
	$(MAKE) composer-install
	$(MAKE) npm-install
	$(MAKE) key-generate
	$(MAKE) storage-link
	sleep 10
	@echo "$(GREEN)⏳ Aguardando para geração das migrations!$(NC)"
	@while ! $(COMPOSE) exec $(PHP_SERVICE) php artisan migrate:status; do \
		echo "$(YELLOW)⏳ Aguardando migrações...$(NC)"; \
		sleep 5; \
	done
	$(MAKE) npm-audit-fix
	$(MAKE) migrate-fresh
	$(MAKE) cache-clear
	$(MAKE) config-all
	$(MAKE) permission
	@echo "$(GREEN)✅ Ambiente configurado com sucesso!$(NC)"

.PHONY: dev-reset
dev-reset: ## Reset completo do ambiente de desenvolvimento
	@echo "$(RED)🔄 Resetando ambiente de desenvolvimento...$(NC)"
	$(MAKE) downv
	$(MAKE) clean
	$(MAKE) dev-setup

.PHONY: quick-test
quick-test: ## Teste rápido do ambiente
	@echo "$(CYAN)🧪 Testando ambiente...$(NC)"
	$(MAKE) status
	$(MAKE) health
	@echo "$(GREEN)✅ Teste concluído!$(NC)"

.PHONY: backup
backup: ## Cria backup do banco de dados
	@echo "$(BLUE)💾 Criando backup do banco...$(NC)"
	$(COMPOSE) exec $(MYSQL_SERVICE) mysqldump -u root -p laravel > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Backup criado$(NC)"

.PHONY: restore
restore: ## Restaura backup do banco de dados (uso: make restore file="backup.sql")
	@if [ -z "$(file)" ]; then \
		echo "$(RED)❌ Arquivo não especificado. Use: make restore file=\"backup.sql\"$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🔄 Restaurando backup $(file)...$(NC)"
	$(COMPOSE) exec -T $(MYSQL_SERVICE) mysql -u root -p laravel < $(file)
	@echo "$(GREEN)✅ Backup restaurado$(NC)"

# =============================================================================
# PRODUÇÃO
# =============================================================================

.PHONY: prod-setup
prod-setup: ## Configuração para produção
	@echo "$(BLUE)🚀 Configurando para produção...$(NC)"
	$(MAKE) down
	$(COMPOSE) -f docker-compose.yml -f docker-compose.prod.yml up -d --build
	$(MAKE) composer-install --no-dev
	$(MAKE) npm-build
	$(MAKE) migrate
	$(MAKE) optimize
	$(MAKE) cache-clear
	$(MAKE) config-all
	@echo "$(GREEN)✅ Produção configurada$(NC)"

.PHONY: prod-deploy
prod-deploy: ## Deploy em produção
	@echo "$(BLUE)🚀 Fazendo deploy...$(NC)"
	git pull origin main
	$(MAKE) prod-setup
	@echo "$(GREEN)✅ Deploy concluído$(NC)"
