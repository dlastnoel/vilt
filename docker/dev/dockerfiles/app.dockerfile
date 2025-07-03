# Alpine slim-based image
FROM php:8.4-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

# Create and point to the working directory
WORKDIR /var/www/html

# Build phase 1: Get composer from official hub image
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# dialout remove (conflict with MacOS) + add user laravel
RUN delgroup dialout && \
    addgroup -g ${GID} --system laravel && \
    adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel && \
    chown -R laravel:laravel /var/www/html

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Build phase 2: Install necessary PHP extensions

# gd
RUN apk add --no-cache \
    libpng libpng-dev \
    && docker-php-ext-install gd \
    && apk del libpng-dev

# zip
RUN apk add --no-cache \
    libzip-dev \
    zip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip

# int
RUN apk add --no-cache --virtual .intl-deps icu-dev zlib-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && apk del .intl-deps

# mysql
RUN docker-php-ext-install pdo_mysql

# redis
RUN apk add --no-cache --virtual .redis-deps pcre-dev $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .redis-deps

# openssl
RUN apk add --no-cache openssl

# node / npm
RUN apk add --no-cache nodejs npm

# clear cache
RUN rm -rf /var/cache/apk/*

# set user to root
USER laravel

# run php
CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
