# 🔒 Guia de Segurança do Hook Pre-Push

## Visão Geral

Este hook pre-push implementa várias camadas de segurança para proteger o repositório contra vulnerabilidades comuns e ataques maliciosos.

## 🛡️ Medidas de Segurança Implementadas

### 1. **Proteção contra Injeção de Comando**
- ✅ Validação de comandos antes da execução
- ✅ Sanitização de strings de entrada
- ✅ Rejeição de caracteres perigosos (`;&|`$(){}[]<>`)

### 2. **Proteção contra Path Traversal**
- ✅ Validação de caminhos de arquivo
- ✅ Verificação de diretórios base
- ✅ Sanitização de cache keys

### 3. **Validação de Arquivos Staged**
- ✅ Verificação de arquivos fora do repositório
- ✅ Detecção de path traversal em nomes de arquivo
- ✅ Validação de integridade dos arquivos

### 4. **Verificação de Vulnerabilidades**
- ✅ Detecção de funções perigosas em PHP
- ✅ Identificação de possíveis SQL injection
- ✅ Verificação de credenciais expostas

### 5. **Integridade do Repositório**
- ✅ Verificação de corrupção do Git
- ✅ Detecção de commits órfãos
- ✅ Validação de permissões de arquivos sensíveis

## ⚠️ Vulnerabilidades Críticas Corrigidas

### Antes (Vulnerável)
```bash
# ❌ Injeção de comando possível
if timeout $timeout sh -c "$command"; then

# ❌ Path traversal possível
local cache_file="$CACHE_DIR/$cache_key"

# ❌ Execução de código arbitrário
source "$CONFIG_FILE"
```

### Depois (Seguro)
```bash
# ✅ Validação de comando
if echo "$command" | grep -qE '[;&|`$(){}[\]<>]'; then
    log "ERROR" "❌ Comando rejeitado por segurança: $command"
    return 1
fi

# ✅ Sanitização de cache key
local sanitized_key=$(validate_cache_key "$cache_key")

# ✅ Carregamento seguro de configuração
while IFS='=' read -r key value; do
    if [[ $key =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        export "$key=$value"
    fi
done < "$CONFIG_FILE"
```

## 🔍 Verificações de Segurança

### 1. **Análise de Código PHP**
- Detecta funções perigosas: `eval`, `exec`, `system`, `shell_exec`
- Identifica padrões de SQL injection
- Verifica uso inseguro de variáveis superglobais

### 2. **Verificação de Credenciais**
- Procura por padrões de senhas e chaves
- Verifica arquivos de configuração sensíveis
- Alerta sobre possíveis vazamentos

### 3. **Validação de Dependências**
- Verifica vulnerabilidades no `composer.lock`
- Valida integridade das dependências
- Alerta sobre dependências desatualizadas

## 🚨 Alertas de Segurança

O hook gera alertas para:
- ⚠️ Funções perigosas encontradas
- ⚠️ Possíveis SQL injection
- ⚠️ Credenciais expostas
- ⚠️ Permissões muito abertas
- ⚠️ Arquivos fora do repositório
- ⚠️ Path traversal detectado

## 📋 Configuração de Segurança

### Habilitar/Desabilitar Verificações
```bash
# .husky/pre-push.config
ENABLE_SECURITY_CHECK=true
ENABLE_CACHE=true
ENABLE_LINT_STAGED=true
```

### Timeouts de Segurança
```bash
TIMEOUT_SECONDS=300  # 5 minutos máximo
```

## 🔧 Melhorias Futuras

1. **Integração com SAST/DAST**
   - SonarQube
   - OWASP ZAP
   - Semgrep

2. **Verificação de Secrets**
   - TruffleHog
   - GitGuardian
   - Pre-commit hooks

3. **Análise de Dependências**
   - Snyk
   - OWASP Dependency Check
   - Composer audit

## 📞 Reportar Vulnerabilidades

Se você encontrar uma vulnerabilidade de segurança:
1. Não abra um issue público
2. Entre em contato com a equipe de segurança
3. Forneça detalhes específicos da vulnerabilidade

## 📚 Recursos Adicionais

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Git Security Best Practices](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [Shell Script Security](https://mywiki.wooledge.org/BashPitfalls) 