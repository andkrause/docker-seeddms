FROM php:7.4-apache AS builder
ARG SEEDDMS_VERSION=6.0.8

RUN curl -fsSL https://downloads.sourceforge.net/project/seeddms/seeddms-${SEEDDMS_VERSION}/seeddms-quickstart-${SEEDDMS_VERSION}.tar.gz | tar -xzC /var/www \
    && mv /var/www/seeddms60x /var/www/seeddms && touch /var/www/seeddms/conf/ENABLE_INSTALL_TOOL

COPY sources/settings.xml /var/www/seeddms/conf/settings.xml

RUN chown -R www-data:www-data /var/www/seeddms/
    


FROM php:7.4-apache
LABEL maintainer="Ralph Pavenstaedt<ralph@pavenstaedt.com>"

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
    && a2enmod rewrite \
## Slim down apt
    && rm -rf /var/lib/apt/lists/*
# Install Seeddms from builder
COPY --from=builder /var/www /var/www


# Copy settings-files
COPY sources/php.ini /usr/local/etc/php/
COPY sources/000-default.conf /etc/apache2/sites-available/


# Volumes to mount
VOLUME [ "/var/www/seeddms/data", "/var/www/seeddms/conf", "/var/www/seeddms/www/ext" ]