FROM alpine:3.14

RUN adduser -u 1000 -D -S -G www-data www-data

RUN apk -U update && \
    apk -U upgrade && \
    apk -U add --no-cache \
        bash \
        coreutils \
        ca-certificates \
        shadow \
        curl \
        git \
        nginx \
        php8 \
        php8-fpm \
        php8-curl \
        php8-dom \
        php8-gettext \
        php8-xml \
        php8-simplexml \
        php8-zip \
        php8-zlib \
        php8-gd \
        php8-openssl \
        php8-mysqli \
        php8-pdo \
        php8-pdo_mysql \
        php8-pgsql \
        php8-pdo_pgsql \
        php8-sqlite3 \
        php8-pdo_sqlite \
        php8-json \
        php8-mbstring \
        php8-ctype \
        php8-opcache \
        php8-session 



RUN git clone --depth=1 --branch 1.5.1 https://github.com/spotweb/spotweb.git /app

RUN mkdir /app/cache

RUN chown -R www-data:www-data /app

RUN mkdir /run/php
RUN chown -R www-data:www-data /run/php

#RUN echo "*/5       *       *       *       *       run-parts /etc/periodic/5min" >> /etc/crontabs/root

# Configure Spotweb
#COPY ./conf/spotweb /app

# Copy root filesystem
COPY etc /etc
COPY entrypoint.sh /etc/entrypoint.sh

RUN chmod +x /etc/entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "sh", "/etc/entrypoint.sh" ]