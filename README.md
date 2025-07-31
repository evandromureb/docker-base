# 🚀 Laravel Docker Base Project

[![PHP](https://img.shields.io/badge/PHP-8.2%2B-blue.svg)](https://php.net)
[![Laravel](https://img.shields.io/badge/Laravel-12.0-red.svg)](https://laravel.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Um ambiente de desenvolvimento Laravel completo e otimizado usando Docker, com suporte a PHP 8.4, Node.js 18, MySQL 8, Nginx, Redis e Mailpit.

## 📋 Índice

- [✨ Funcionalidades](#-funcionalidades)
- [🚀 Início Rápido](#-início-rápido)
- [📦 Pré-requisitos](#-pré-requisitos)
- [🔧 Instalação](#-instalação)
- [⚡ Comandos Make](#-comandos-make)
- [🏗️ Arquitetura](#️-arquitetura)
- [🌐 Acessos](#-acessos)
- [🛠️ Desenvolvimento](#️-desenvolvimento)
- [🧪 Testes](#-testes)
- [📊 Qualidade de Código](#-qualidade-de-código)
- [🔍 Troubleshooting](#-troubleshooting)
- [📚 Documentação Adicional](#-documentação-adicional)

## ✨ Funcionalidades

### 🐳 **Docker & Infraestrutura**
- **PHP 8.4** com FPM e extensões otimizadas
- **Node.js 18.x** para assets frontend
- **MySQL 8** como banco de dados principal
- **Nginx** como servidor web reverso
- **Redis** para cache e sessões
- **Mailpit** para captura de emails em desenvolvimento
- **Volumes persistentes** para dados e storage

### 🎯 **Laravel 12**
- Framework Laravel mais recente
- **Livewire 3** para componentes dinâmicos
- **Pest** para testes modernos
- **Laravel Pint** para formatação de código
- **PHPStan** para análise estática
- **Rector** para refatoração automática
- **Log Viewer** para visualização de logs

### 🎨 **Frontend**
- **Vite** para build de assets
- **Hot reload** em desenvolvimento
- **Tailwind CSS** (configurável)
- **Alpine.js** (configurável)

### 🧪 **Qualidade & Testes**
- **Pest** para testes modernos
- **PHPStan** para análise estática
- **Laravel Pint** para formatação
- **Rector** para refatoração
- **Git hooks** com Husky

## 🚀 Início Rápido

```bash
# 1. Clone o repositório
git clone git@github.com:evandromureb/docker-base.git
cd docker-base

# 2. Configure o ambiente
cp .env.example .env

# 3. Inicie tudo com um comando
make dev-setup

# 4. Acesse a aplicação
open http://localhost
```

## 📦 Pré-requisitos

- [Docker](https://www.docker.com/) (versão 20.10+)
- [Docker Compose](https://docs.docker.com/compose/) (versão 2.0+)
- [Make](https://www.gnu.org/software/make/) (opcional, mas altamente recomendado)
- [Git](https://git-scm.com/)

### 🐧 **Linux/WSL**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose make

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
```

### 🪟 **Windows**
- Instale [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Use WSL2 para melhor performance
- Instale [Make for Windows](https://gnuwin32.sourceforge.net/packages/make.htm)

### 🍎 **macOS**
```bash
# Via Homebrew
brew install docker docker-compose make

# Ou instale Docker Desktop
```

## 🔧 Instalação

### **Método 1: Setup Automático (Recomendado)**

```bash
# Clone e configure tudo automaticamente
git clone git@github.com:evandromureb/docker-base.git
cd docker-base
cp .env.example .env
make dev-setup
```

### **Método 2: Setup Manual**

```bash
# 1. Clone o repositório
git clone git@github.com:evandromureb/docker-base.git
cd docker-base

# 2. Configure o ambiente
cp .env.example .env
# Edite o .env conforme necessário

# 3. Instale dependências
make composer-install
make npm-install

# 4. Configure Laravel
make key-generate
make storage-link

# 5. Inicie os containers
make upb

# 6. Execute migrações
make migrate-fresh
```

## ⚡ Comandos Make

O projeto inclui um **Makefile completo** com mais de 50 comandos úteis:

### 🐳 **Docker Compose**
```bash
make up          # Inicia containers
make upb         # Inicia com rebuild
make down        # Para containers
make downv       # Para e remove volumes
make restart     # Reinicia containers
make build       # Constrói imagens
make logs        # Mostra logs
make status      # Status dos containers
```

### 🎯 **Laravel**
```bash
make bash        # Acessa container PHP
make shell       # Acessa Tinker
make artisan cmd="migrate"  # Comando artisan genérico
make migrate     # Executa migrações
make migrate-fresh  # Migrações + seed
make seed        # Executa seeders
make cache-clear # Limpa caches
```

### 📦 **Dependências**
```bash
make composer-install    # Instala dependências PHP
make composer-update     # Atualiza dependências PHP
make npm-install         # Instala dependências Node
make npm-dev             # Executa npm run dev
make npm-build           # Executa npm run build
```

### 🏗️ **Desenvolvimento**
```bash
make make-controller name="UserController"  # Cria controller
make make-model name="User"                 # Cria model
make make-migration name="create_users"     # Cria migration
make make-seeder name="UserSeeder"          # Cria seeder
```

### 🧪 **Testes & Qualidade**
```bash
make test        # Executa testes
make test-pest   # Executa testes Pest
make pint        # Formata código
make phpstan     # Análise estática
make rector      # Refatoração automática
```

### 🚀 **Desenvolvimento Rápido**
```bash
make dev-setup   # Setup completo inicial
make dev-reset   # Reset completo do ambiente
make help        # Lista todos os comandos
```

## 🏗️ Arquitetura

```
📁 docker-base/
├── 🐳 docker/
│   ├── Dockerfile          # Imagem PHP + Node.js
│   ├── nginx.conf          # Configuração Nginx
│   └── php.ini             # Configuração PHP
├── 📄 docker-compose.yml   # Orquestração dos serviços
├── 📄 Makefile            # Comandos de desenvolvimento
├── 📄 .env.example        # Variáveis de ambiente
└── 📁 app/                # Código Laravel
```

### **Serviços Docker**

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| **PHP** | - | Container principal com PHP 8.4 + Node.js 18 |
| **Nginx** | 80 | Servidor web reverso |
| **MySQL** | 3306 | Banco de dados |
| **Redis** | 6379 | Cache e sessões |
| **Mailpit** | 8025 | Captura de emails |

### **Volumes Persistentes**

- `./:/var/www` - Código da aplicação
- `storage_data:/var/www/storage` - Storage do Laravel
- `db_data:/var/lib/mysql` - Dados do MySQL

## 🌐 Acessos

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **Aplicação** | http://localhost | - |
| **Mailpit** | http://localhost:8025 | - |
| **MySQL** | localhost:3306 | Ver `.env` |
| **Redis** | localhost:6379 | - |

## 🛠️ Desenvolvimento

### **Estrutura de Desenvolvimento**

```bash
# 1. Iniciar ambiente
make up

# 2. Acessar container
make bash

# 3. Desenvolvimento frontend
make npm-dev

# 4. Ver logs
make logs

# 5. Testes
make test
```

### **Workflow Típico**

```bash
# Desenvolvimento diário
make up                    # Inicia containers
make bash                  # Acessa container
# ... desenvolve ...
make test                  # Executa testes
make pint                  # Formata código
make phpstan               # Verifica qualidade
```

### **Comandos Úteis**

```bash
# Criar nova funcionalidade
make make-controller name="UserController"
make make-model name="User"
make make-migration name="create_users_table"
make migrate

# Qualidade de código
make pint
make phpstan
make test

# Debug
make logs-php
make shell
```

## 🧪 Testes

### **Executando Testes**

```bash
# Todos os testes
make test

# Testes com cobertura
make test-coverage

# Testes Pest
make test-pest

# Testes específicos
make artisan cmd="test --filter=UserTest"
```

### **Configuração de Testes**

- **Pest** para testes modernos
- **PHPUnit** como fallback
- **Faker** para dados de teste
- **Mockery** para mocks

## 📊 Qualidade de Código

### **Ferramentas Integradas**

```bash
# Formatação
make pint              # Formata código
make pint-check        # Verifica formatação

# Análise estática
make phpstan           # Análise PHPStan

# Refatoração
make rector            # Refatoração automática

# Testes
make test              # Executa testes
```

### **Padrões de Código**

- **PSR-12** via Laravel Pint
- **PHPStan** para análise estática
- **Git hooks** com Husky
- **EditorConfig** para consistência

## 🔍 Troubleshooting

### **Problemas Comuns**

#### **1. Portas em Uso**
```bash
# Verificar portas
sudo lsof -i :80
sudo lsof -i :3306

# Parar serviços conflitantes
sudo service apache2 stop
sudo service mysql stop
```

#### **2. Permissões**
```bash
# Corrigir permissões
make permission

# Ou manualmente
sudo chmod -R 777 ./
```

#### **3. Containers Não Iniciam**
```bash
# Verificar logs
make logs

# Rebuild completo
make dev-reset
```

#### **4. Dependências Desatualizadas**
```bash
# Reinstalar tudo
make composer-install
make npm-install
make cache-clear
```

#### **5. Banco de Dados**
```bash
# Reset completo
make migrate-fresh

# Verificar status
make migrate-status
```

### **Logs Úteis**

```bash
# Todos os logs
make logs

# Logs específicos
make logs-php
make logs-nginx
make logs-mysql
```

## 📚 Documentação Adicional

- [📖 README-Docker.md](README-Docker.md) - Documentação detalhada do Docker
- [🐳 Docker Documentation](https://docs.docker.com/)
- [🎯 Laravel Documentation](https://laravel.com/docs)
- [🧪 Pest Documentation](https://pestphp.com/)
- [🎨 Vite Documentation](https://vitejs.dev/)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- [Laravel](https://laravel.com/) - Framework PHP
- [Docker](https://docker.com/) - Containerização
- [Pest](https://pestphp.com/) - Framework de testes
- [Laravel Pint](https://laravel.com/docs/pint) - Formatação de código

---

**⭐ Se este projeto te ajudou, considere dar uma estrela!**
