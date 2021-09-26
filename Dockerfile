FROM php:7.4-fpm

ARG COCKPIT_VERSION="master"

RUN apt-get update \
    && apt-get install -y \
    wget zip unzip vim nano git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libpng-dev \
    sqlite3 libsqlite3-dev \
    libssl-dev \
    libzip-dev \
    && pecl install mongodb \
    && pecl install redis \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp  \
    && docker-php-ext-install -j$(nproc) iconv gd pdo zip opcache pdo_sqlite

# PHP CONFIGURATION
RUN echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
    && echo "opcache.revalidate_freq=0" > /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini

# COCKPIT CONFIGURATION
# cesta musi byt /var/www/cockpit aby byla stejna i v nginxu
RUN wget https://github.com/agentejo/cockpit/archive/${COCKPIT_VERSION}.zip -O /tmp/cockpit.zip \
    && unzip /tmp/cockpit.zip -d /tmp/ \
    && rm /tmp/cockpit.zip \
    && mv /tmp/cockpit-${COCKPIT_VERSION} /var/www/cockpit \
    && git clone https://github.com/raffaelj/cockpit_ImageResize.git /var/www/cockpit/addons/ImageResize

# COCKPIT HACK TO HAVE FILES WITH 770/660 PERMISSIONS
COPY src/lib/vendor/league/flysystem/src/Adapter/Local.php /var/www/cockpit/lib/vendor/league/flysystem/src/Adapter/Local.php

RUN chmod -R 777 /var/www/cockpit

WORKDIR /var/www/cockpit

CMD ["php-fpm"]