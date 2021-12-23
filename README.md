# Docker file for Spotweb using Nginx and php-fpm

A docker image containing spotweb hosted using nginx and php-fpm.
Used the following image definitions as inspiration:
- https://github.com/steynovich/docker-spotweb
- https://github.com/jgeusebroek/docker-spotweb/
- https://github.com/edv/docker-spotweb/

## Quick Setup
A docker-compose is included to automatically start a postgresql database together with the spotweb application. 

It will automatically initialize the database if needed, populate it with the provided admin user information and configure it for the requested system type.
If the database is already configured it will not alter the admin user or system type anymore.

## Reason

None of the existing images follow the version tagging of the spotweb repository (https://github.com/spotweb/). Also you often need to run it first without environment variables to be able to go through the installation wizard, and then shutdown and start again with the environment variables.

What this image adds is additional environment variables so you can configure Spotweb with all the information you supply during the install wizard. With exception of the newsserver settings. These need to be added using the settings once the application is up and running.

During startup it will check the status of the configured database and upgrade if needed, or initialize with the provided admin user and system type if it is the first run.

## Environment Variables

| Variable          | Possible/Sample Values | Description |
|------------------ | ---------------------- | ----------- |
|TZ                 | Europe/Brussels        | The (PHP) timezone to use |
|SPOTWEB_SYSTEMTYPE | single                 | How will you run spotweb |
|SPOTWEB_USERNAME   | myawesomeuser          | The admin username |
|SPOTWEB_PASSWORD   | ******                 | The admin password |
|SPOTWEB_FIRSTNAME  | demo                   | The admin his first name |
|SPOTWEB_LASTNAME   | spotweb                | The admin his last name |
|SPOTWEB_MAIL       | demo@spotweb.com       | The admin his email |
|SPOTWEB_RETRIEVE   | 15min                  | The schedule on which to retrieve new spots |
|DB_ENGINE          | pdo_pgsql              | The database type to use |
|DB_HOST            | db                     | The host adres of the database |
|DB_PORT            | 5432                   | The database port to use |
|DB_DATABASE        | spotweb                | The name of the database to use |
|DB_USER            | spotweb                | The database user to use |
|DB_PASSWORD        | *******                | The databzase password to use for the provided user |
|DB_SCHEMA          | public                 | The database schema to use for the tables inside the provided database |

### System Type Options

Following system types are supported:

***Single user	(single)***

Single user systems are one-user systems, not shared with friends or family members. Spotweb wil always be logged on using the below defined user and Spotweb will never ask for authentication.

***Shared (shared)***

Shared systems are Spotweb installations shared among friends or family members. You do have to logon using an useraccount, but the users who do log on are trusted to have no malicious intentions.

***Public (public)***

Public systems are Spotweb installations fully open to the public. Because the installation is fully open, regular users do not have all the features available in Spotweb to help defend against certain malicious users.

### Retrieve spots schedule options
Following schedules are supported to configure the automatic spot retrieval:
- 1min 
- 5min 
- 15min 
- hourly 
- daily 
- weekly 
- monthly

### DB Engine options
This container supports 2 database types:
- MySQL: use pdo_mysql as engine value
- PostgreSQL: use pdo_pgsql as engine value