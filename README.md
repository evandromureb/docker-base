# Docker PHP Base Project

Projeto em PHP com suporte a Composer, NPM, MySQL, Nginx e Mailpit via Docker.

## Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Make](https://www.gnu.org/software/make/) (opcional, mas recomendado)

## Como iniciar o projeto

Clone o repositório e utilize os comandos abaixo para gerenciar o ambiente:

### Comandos principais (`Makefile`)

- `make up`  
  Sobe os containers em modo detach.

- `make down`  
  Para e remove os containers.

- `make build`  
  Faz o build das imagens Docker.

- `make bash`  
  Acessa o terminal do container PHP.

- `make composer-install`  
  Instala as dependências do Composer.

- `make npm-install`  
  Instala as dependências do NPM.

- `make migrate`  
  Executa as migrations do Laravel.

- `make migrate-fresh`  
  Executa as migrations do zero e faz o seed.

- `make seed`  
  Executa os seeders do banco de dados.

- `make logs`  
  Exibe os logs dos containers.

- `make permission`  
  Ajusta as permissões dos arquivos (Linux).

## Serviços disponíveis

- **PHP**: Ambiente principal da aplicação.
- **Nginx**: Servidor web.
- **MySQL**: Banco de dados.
- **Mailpit**: Ferramenta para captura de e-mails em ambiente de desenvolvimento.

## Acessos

- Aplicação: [http://localhost](http://localhost)
- Mailpit: [http://localhost:8025](http://localhost:8025)
- MySQL: `localhost:3306` (usuário e senha conforme variáveis de ambiente)

## Estrutura dos arquivos

- `docker-compose.yml`: Configuração dos serviços Docker.
- `Makefile`: Comandos utilitários para facilitar o uso do Docker.
- `.editorconfig`: Padrões de formatação de código.

## Observações

- Certifique-se de que as portas 80, 3306 e 8025 estejam livres.
- Para rodar comandos do `Makefile` no Windows, utilize o terminal WSL ou Git Bash.
