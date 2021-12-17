#!/usr/bin/env bash
nginx -c /etc/nginx/nginx.conf &
php-fpm8 -F