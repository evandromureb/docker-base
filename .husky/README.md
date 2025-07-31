# Hooks Git - Husky

Este diretório contém os hooks Git configurados com Husky para garantir qualidade de código.

## Pre-Push Hook

O hook `pre-push` executa verificações automáticas antes de cada push para garantir a qualidade do código.

### ✅ Verificações Executadas

1. **lint-staged** - Formatação e linting de arquivos JS/TS
2. **Dependências** - Verifica se composer e npm estão instalados
3. **PHPStan** - Análise estática de código PHP
4. **Testes** - Executa testes automatizados (Laravel)
5. **Laravel Pint** - Formatação automática de código PHP
6. **PHP CS Fixer** - Verificação adicional de estilo (opcional)
7. **Security Checker** - Verificação de vulnerabilidades (opcional)

### ⚡ Recursos Avançados

- **Cache inteligente** - Evita re-executar verificações desnecessárias
- **Timeout configurável** - Previne travamentos
- **Logging detalhado** - Timestamps e níveis de log
- **Configuração flexível** - Arquivo `.husky/pre-push.config`
- **Feedback visual** - Cores e emojis para melhor UX

### 🔧 Configuração

Edite o arquivo `.husky/pre-push.config` para personalizar:

```bash
# Desabilitar uma verificação
ENABLE_TESTS=false

# Ajustar timeout
TESTS_TIMEOUT=300  # 5 minutos

# Desabilitar cache
ENABLE_CACHE=false
```

### 📊 Exemplo de Saída

```
[14:30:15] INFO: 🚀 Iniciando verificações pre-push...
[14:30:15] INFO: 📋 Carregando configuração de .husky/pre-push.config
[14:30:15] INFO: 📋 Encontrados 3 arquivo(s) staged para verificação:
  📄 app/Models/User.php
  📄 resources/js/components/Button.vue
  📄 tests/Feature/UserTest.php
[14:30:16] INFO: 🚀 Executando lint-staged...
[14:30:18] SUCCESS: ✅ lint-staged concluído com sucesso
[14:30:18] INFO: 🔍 Verificando dependências...
[14:30:18] SUCCESS: ✅ Dependências PHP verificadas
[14:30:18] SUCCESS: ✅ Dependências Node.js verificadas
[14:30:19] INFO: 📄 Analisando arquivos PHP com PHPStan...
  📄 app/Models/User.php
[14:30:21] SUCCESS: ✅ análise PHPStan concluído com sucesso
[14:30:22] INFO: 🚀 Executando testes...
[14:30:25] SUCCESS: ✅ testes concluído com sucesso
[14:30:26] INFO: 🎨 Formatando arquivos PHP com Laravel Pint...
  🎨 app/Models/User.php
[14:30:26] SUCCESS: ✅ Arquivos formatados com Laravel Pint
[14:30:26] SUCCESS: 🎉 Todas as verificações pre-push concluídas com sucesso!
```

### 🚨 Troubleshooting

#### Hook não executa
```bash
# Verificar se o hook está executável
chmod +x .husky/pre-push

# Verificar se Husky está instalado
npm list husky
```

#### Timeout muito baixo
Aumente os valores de timeout no arquivo de configuração:
```bash
TESTS_TIMEOUT=600  # 10 minutos
```

#### Cache causando problemas
```bash
# Limpar cache
rm -rf .husky/cache

# Ou desabilitar cache
ENABLE_CACHE=false
```

#### Pular verificações temporariamente
```bash
# Pular hook (não recomendado)
git push --no-verify

# Ou desabilitar verificações específicas no config
ENABLE_TESTS=false
```

### 📁 Estrutura de Arquivos

```
.husky/
├── pre-push              # Hook principal
├── pre-push.config       # Configuração
├── cache/                # Cache de verificações
└── README.md            # Esta documentação
```

### 🔄 Cache

O sistema de cache evita re-executar verificações desnecessárias:

- **Duração**: 1 hora por padrão
- **Localização**: `.husky/cache/`
- **Configuração**: `CACHE_DURATION` no arquivo de config

### ⏱️ Timeouts

Timeouts padrão para evitar travamentos:

- **lint-staged**: 2 minutos
- **PHPStan**: 3 minutos  
- **Testes**: 4 minutos
- **CS Fixer**: 1 minuto
- **Security Check**: 1 minuto

### 🎯 Dicas

1. **Desenvolva com verificações habilitadas** para detectar problemas cedo
2. **Ajuste timeouts** conforme a velocidade da sua máquina
3. **Use cache** para acelerar verificações subsequentes
4. **Configure verificações** conforme as necessidades do projeto
5. **Monitore logs** para identificar gargalos 