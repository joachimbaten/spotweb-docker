#!/bin/sh

# Set Time Zone
TZ=${TZ:-"Europe/Amsterdam"}
echo -e "Setting (PHP) time zone to ${TZ}\n"
sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g"  /etc/php8/conf.d/spotweb.ini

# Init DB
if ! /root/init_db.sh ; then
    echo "Failed to initialize database!"
    exit 1
fi

# Start nginx server
nginx -c /etc/nginx/nginx.conf &

# Start php-fpm
php-fpm8 -F