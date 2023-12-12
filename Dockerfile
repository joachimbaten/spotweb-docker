FROM alpine:latest

#RUN adduser -u 1000 -D -S -G www-data www-data

RUN apk -U update && \
    apk -U upgrade && \
    apk -U add --no-cache --virtual .spotweb-rundeps \
        bash \
        curl \
		libldap \
		libsasl \
		mariadb-client \
        postgresql-client \
        nginx \
        supervisor \
        php82 \
        php82-fpm \
        php82-curl \
        php82-dom \
        php82-gettext \
        php82-xml \
        php82-simplexml \
        php82-zip \
        php82-zlib \
        php82-gd \
        php82-openssl \
        php82-mysqli \
        php82-pdo \
        php82-pdo_mysql \
        php82-pgsql \
        php82-pdo_pgsql \
        php82-sqlite3 \
        php82-pdo_sqlite \
        php82-json \
        php82-mbstring \
        php82-ctype \
        php82-opcache \
        php82-session 

# Install Spotweb
RUN apk add --no-cache --virtual .spotweb-deploydeps git \
	&& git clone --depth=1 --branch develop https://github.com/spotweb/spotweb.git /app \
	&& mkdir -m777 /app/cache \
    && apk del .spotweb-deploydeps

# Create additional periodic folders for cron
RUN mkdir /etc/periodic/1min \
    && mkdir /etc/periodic/5min

RUN echo "*/5     *       *       *       *       run-parts /etc/periodic/5min" >> /etc/crontabs/root
RUN echo "*/1     *       *       *       *       run-parts /etc/periodic/1min" >> /etc/crontabs/root

# Copy configuration files
COPY /config /

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh

# Fix App Permissions and ensure entrypoint is executable
RUN chown -R nginx: /app \
    && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "sh", "/entrypoint.sh" ]