FROM php:8.3-apache

# Activer mod_rewrite
RUN a2enmod rewrite

# Installer dépendances système + PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales git unzip libicu-dev g++ libpng-dev libxml2-dev libzip-dev libonig-dev libxslt-dev libpq-dev wget curl \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_mysql intl zip dom mbstring xsl gd \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Config Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Config PHP
COPY .docker/php.ini /usr/local/etc/php/conf.d/custom.ini

# Dossier de travail
WORKDIR /var/www/html

# Optimisation build vendors
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-scripts --no-progress --no-suggest || true
COPY . .
