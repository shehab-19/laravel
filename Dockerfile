# Start from the official PHP image with Apache
FROM php:8.2-apache

# Update package lists and install required system packages and PHP extensions for Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev git unzip curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Download and install Composer, a PHP package manager
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable the Apache rewrite module for Laravel support
RUN a2enmod rewrite

# Define the working directory inside the container
WORKDIR /var/www/html

# Copy the Laravel application files into the container
COPY . .

# Adjust file permissions for Laravel directories and files
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Install Laravel dependencies using Composer
RUN composer install --no-interaction --optimize-autoloader

# Set up Apache to serve the Laravel public directory
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80 to allow web traffic
EXPOSE 80

# Command to run Apache in the foreground
CMD ["apache2-foreground"]
