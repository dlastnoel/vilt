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
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    freetype-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install gd

# imagick
RUN apk add --update --no-cache $PHPIZE_DEPS imagemagick imagemagick-libs
RUN apk add --update --no-cache --virtual .docker-php-imagick-dependencies imagemagick-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apk del .docker-php-imagick-dependencies

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

# exif
RUN docker-php-ext-install exif &&  \
    docker-php-ext-enable exif

# redis
RUN apk add --no-cache --virtual .redis-deps pcre-dev $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .redis-deps

# openssl
RUN apk add --no-cache openssl

# image optimizers
RUN apk add --no-cache \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    nodejs

# node / npm
RUN apk add --no-cache nodejs npm

# clear cache
RUN rm -rf /var/cache/apk/*

# set user to root
USER laravel

# run php
CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
