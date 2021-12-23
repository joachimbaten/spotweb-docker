#!/bin/sh

# Determine database engine
SQL=""

if [ $DB_ENGINE = "pdo_mysql" ]; then
    echo "Checking if MYSQL DB is online"

    SQL="mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PASSWORD} ${DB_DATABASE} -s -e"
fi;

if [ $DB_ENGINE = "pdo_pgsql" ]; then
    echo "Checking if PostgreSQL DB is online"
    # postgresql://[user[:password]@][netloc][:port][/dbname]
    SQL="psql -At --echo-all --set ON_ERROR_STOP=on postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DATABASE} -c"
fi

# Wait for database to startup
maxcounter=10
counter=1
while [ 1 ]; do
    sleep 5
    echo -e "Attempt ${counter} (Host: ${DB_HOST}:${DB_PORT} - User: ${DB_USER} - Database: ${DB_DATABASE})"
    $SQL "select 1" > /dev/null 2>&1 && break
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 echo "We have been waiting for the database too long already; failing."
        exit 1
    fi;
done

echo "Database is online."

# Save db settings
{ 
    echo '<?php'; \
    echo '$dbsettings["engine"] = "'${DB_ENGINE}'";'; \
    echo '$dbsettings["host"] = "'${DB_HOST}'";'; \
    echo '$dbsettings["dbname"] = "'${DB_DATABASE}'";'; \
    echo '$dbsettings["user"] = "'${DB_USER}'";'; \
    echo '$dbsettings["pass"] = "'${DB_PASSWORD}'";'; \
    echo '$dbsettings["port"] = "'${DB_PORT}'";'; \
    echo '$dbsettings["schema"] = "'${DB_SCHEMA}'";'; \
    echo '?>'; \
} | tee /app/dbsettings.inc.php

# Check if tables exists and create them if not
$SQL "select count(*) from settings" > /dev/null 2>&1
retval=$?
if [ $retval == 1 ]; then
   echo "Initializing database"
   /usr/bin/php8 /app/bin/init-db.php
   echo "Database initialization complete."
else
   echo "Database already exists - upgrading"
   /usr/bin/php8 /app/bin/upgrade-db.php
   echo "Database upgrade complete."
fi

exit 0