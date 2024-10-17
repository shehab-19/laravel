# Use the official PHP image as a base
FROM php:8.2-fpm-alpine

# Set the working directory
WORKDIR /var/www

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    oniguruma-dev \
    bash \
    curl \
    git \
    postgresql-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql pdo_pgsql

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy the Laravel app files
COPY . .

# Install Composer dependencies without dev packages
RUN composer install --no-dev --optimize-autoloader

# Set permissions for Laravel storage and bootstrap/cache directories
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Set environment variables
ENV APP_ENV=production \
    APP_DEBUG=false \
    APP_KEY=your-app-key-here

# Expose the port for PHP-FPM
EXPOSE 9000

# Start the PHP-FPM server
CMD ["php-fpm"]
