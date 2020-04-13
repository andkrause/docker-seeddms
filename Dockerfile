FROM php:7.4-fpm

# Update and install necessary packages
RUN apt-get update \
    && apt-get install libpq-dev imagemagick id3 poppler-utils catdoc xpdf html2text docx2txt zlib1g-dev libpng-dev -y \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install gd mysqli pdo pdo_mysql pdo_pgsql \
    && pear channel-update pear.php.net \
    && pear install Log \
    && pear install Mail \
    && pear install Net_SMTP \
    && pear install HTTP_WebDAV_Server-1.0.0RC8 \
## Slim down apt
    && rm -rf /var/lib/apt/lists/*

# Copy settings-files
COPY php.ini $PHP_INI_DIR/


# Volumes to mount
#VOLUME [ "/var/www/seeddms/data", "/var/www/seeddms/conf", "/var/www/seeddms/www/ext" ]