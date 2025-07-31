FROM php:8.4-fpm AS builder

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

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /var/www

COPY . .

RUN groupadd -r appuser && useradd -r -g appuser appuser

RUN chown -R appuser:appuser /var/www \
    && mkdir -p /var/www/storage/logs \
    && mkdir -p /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

USER appuser

RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && if [ -f package.json ]; then npm ci --only=production --ignore-scripts; fi

FROM php:8.4-fpm

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

RUN groupadd -r appuser && useradd -r -g appuser appuser \
    && echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY --from=builder /usr/bin/composer /usr/bin/composer

COPY --from=builder /usr/local/etc/php/conf.d/custom.ini /usr/local/etc/php/conf.d/
COPY --from=builder /entrypoint.sh /entrypoint.sh


COPY --from=builder --chown=appuser:appuser /var/www /var/www

RUN chmod +x /entrypoint.sh \
    && chown -R appuser:appuser /var/www \
    && chmod -R 775 /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/vendor \
    && chmod -R 775 /var/www/node_modules \
    && chmod -R 775 /var/www/docker \
    && mkdir -p /var/www/storage/logs \
    && chmod -R 775 /var/www/storage/logs \
    && touch /var/www/storage/logs/laravel.log \
    && chown -R appuser:appuser /var/www/storage/logs



RUN mkdir -p /home/appuser && chown -R appuser:appuser /home/appuser
RUN chown -R appuser:appuser /var/www/node_modules

WORKDIR /var/www

USER appuser

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
