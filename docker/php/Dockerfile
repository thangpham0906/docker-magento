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
    zip \
    unzip \
    vim \
    wget \
    cron \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Magento 2.4.8
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    intl \
    mysqli \
    pdo_mysql \
    opcache \
    soap \
    sockets \
    sodium \
    xsl \
    zip

# Install Xdebug (for development)
# RUN pecl install xdebug-3.3.2 \
#     && docker-php-ext-enable xdebug

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create Magento cron user
RUN useradd -m -s /bin/bash magento

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
