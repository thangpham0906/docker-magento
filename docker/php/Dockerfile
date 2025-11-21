FROM php:8.4-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libxslt1-dev \
    libsodium-dev \
    libssl-dev \
    libkrb5-dev \
    libldap2-dev \
    libmemcached-dev \
    libpq-dev \
    libsqlite3-dev \
    zip \
    unzip \
    vim \
    wget \
    cron \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Magento 2.4.8 and additional extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    ftp \
    gd \
    intl \
    ldap \
    mbstring \
    mysqli \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pgsql \
    soap \
    sockets \
    sodium \
    xsl \
    zip

# Install PECL extensions
RUN pecl install xdebug redis memcached apcu \
    && docker-php-ext-enable xdebug redis memcached apcu

# Install Composer 2.8
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Create Magento cron user
RUN useradd -m -s /bin/bash magento

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
