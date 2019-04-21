#!/bin/sh

if [ -f /ttrss/config.php ]; then
    ln -s /ttrss/config.php /var/www/html/config.php
fi

supervisord --nodaemon --configuration /etc/supervisord.conf
