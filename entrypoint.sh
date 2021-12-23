#!/bin/sh

# Set Time Zone
TZ=${TZ:-"Europe/Amsterdam"}
echo -e "Setting (PHP) time zone to ${TZ}\n"
sed -i "s#^date.timezone =.*#date.timezone = ${TZ}#g"  /etc/php8/conf.d/spotweb.ini

# Init DB
if ! /root/init_db.sh ; then
    echo "Failed to initialize database!"
    exit 1
fi

# Configure CRON for automatic spot retrieval
if [ -d "/etc/periodic/${SPOTWEB_RETRIEVE}" ]; then
  echo "Schedule spot retrieval every ${SPOTWEB_RETRIEVE}"
  cp /root/retrieve_spots.sh /etc/periodic/${SPOTWEB_RETRIEVE}/retrieve_spots.sh
  chmod a+x /etc/periodic/${SPOTWEB_RETRIEVE}/retrieve_spots.sh
else
  echo "Warning: /etc/periodic/${SPOTWEB_RETRIEVE} not found. CRON configurations skipped."
fi

# Start needed applications using supervisor
/usr/bin/supervisord