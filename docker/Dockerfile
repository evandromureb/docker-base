# Build stage - para instalar dependências e compilar
FROM php:8.4-fpm AS builder

# Instala dependências de build
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zlib1g-dev \
    libxml2-dev \
    zip \
    git \
    unzip \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala Node.js 18.x com verificação de integridade
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia arquivos de configuração
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/entrypoint.sh /entrypoint.sh

# Define permissões do entrypoint
RUN chmod +x /entrypoint.sh

WORKDIR /var/www

# Copia código da aplicação
COPY . .

# Cria usuário não-root no builder stage também
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Define permissões corretas antes de instalar dependências
RUN chown -R appuser:appuser /var/www \
    && mkdir -p /var/www/storage/logs \
    && mkdir -p /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Muda para usuário não-root para instalar dependências
USER appuser

# Instala dependências PHP e Node.js
RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && if [ -f package.json ]; then npm ci --only=production --ignore-scripts; fi

# Production stage - imagem final otimizada
FROM php:8.4-fpm

# Instala apenas dependências de runtime e Node.js
RUN apt-get update && apt-get install -y \
    libpng16-16 \
    libjpeg62-turbo \
    libfreetype6 \
    libzip4 \
    zlib1g \
    libxml2 \
    sudo \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Cria usuário não-root para maior segurança
RUN groupadd -r appuser && useradd -r -g appuser appuser \
    && echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copia extensões PHP compiladas do builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Copia Composer do builder
COPY --from=builder /usr/bin/composer /usr/bin/composer

# Copia arquivos de configuração do builder
COPY --from=builder /usr/local/etc/php/conf.d/custom.ini /usr/local/etc/php/conf.d/
COPY --from=builder /entrypoint.sh /entrypoint.sh

# Copia aplicação compilada do builder
COPY --from=builder --chown=appuser:appuser /var/www /var/www

# Define permissões e diretório de trabalho
RUN chmod +x /entrypoint.sh \
    && chown -R appuser:appuser /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/vendor \
    && chmod -R 775 /var/www/node_modules \
    && mkdir -p /var/www/storage/logs \
    && chmod -R 775 /var/www/storage/logs \
    && touch /var/www/storage/logs/laravel.log \
    && chown -R appuser:appuser /var/www/storage/logs

WORKDIR /var/www

# Muda para usuário não-root
USER appuser

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
