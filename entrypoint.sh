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

# Configure CRON for automatic spot retrieval
if [ -d "/etc/periodic/${SPOTWEB_RETRIEVE}" ]; then
  echo "Add cron job to /etc/periodic/${SPOTWEB_RETRIEVE}..."
  echo "/usr/bin/php8 /app/retrieve.php" > "/etc/periodic/${SPOTWEB_RETRIEVE}/spotweb"
else
  echo "Warning: /etc/periodic/${SPOTWEB_RETRIEVE} not found. CRON configurations skipped."
fi

# Start Cron
/usr/sbin/crond -f -l 2 &

# Start nginx server
nginx -c /etc/nginx/nginx.conf &

# Start php-fpm
php-fpm8 -F