# Use the official PHP image with Apache
FROM php:8.2-apache

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install zip pdo_mysql \
    && a2enmod rewrite \
    && apt-get install nano

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy the Laravel application files
COPY . .

# Install Laravel dependencies
RUN composer install

# Generate Laravel application key
RUN php artisan key:generate

RUN php artisan migrate

RUN php artisan storage:link

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Set permissions for storage logs directory
RUN chmod -R 775 /var/www/html/storage/logs/

# Update Apache DocumentRoot to the public folder
RUN sed -i -e 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Expose port 80 for Apache
EXPOSE 82

# Start Apache
CMD ["apache2-foreground"]

