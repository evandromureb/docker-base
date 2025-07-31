FROM php:8.4-fpm

# Instala extensões necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev zip git unzip curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install pcov using pecl
RUN pecl install pcov \
	&& docker-php-ext-enable pcov

# Instala Composer
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Copia php.ini customizável
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/entrypoint.sh /entrypoint.sh

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN chmod +x /entrypoint.sh

WORKDIR /var/www

COPY . .
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
