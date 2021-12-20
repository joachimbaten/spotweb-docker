# spotweb-docker
A docker image containing spotweb hosted using nginx and php-fpm

Single user	(single)
Single user systems are one-user systems, not shared with friends or family members. Spotweb wil always be logged on using the below defined user and Spotweb will never ask for authentication.

Shared (shared)
Shared systems are Spotweb installations shared among friends or family members. You do have to logon using an useraccount, but the users who do log on are trusted to have no malicious intentions.

Public (public)
Public systems are Spotweb installations fully open to the public. Because the installation is fully open, regular users do not have all the features available in Spotweb to help defend against certain malicious users.


SPOTWEB_RETRIEVE=15min | hourly | daily

based on
https://github.com/steynovich/docker-spotweb
https://github.com/jgeusebroek/docker-spotweb/
https://github.com/edv/docker-spotweb/