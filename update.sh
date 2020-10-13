#!/bin/sh

if [ "$ENABLE_BOOTSTRAP" = "true" ]; then
    while [ ! -e /bootstrap/complete ]; do
        echo "waiting for bootstrap to complete..."
        sleep 5
    done
fi

if [ "$SKIP_DB_CHECK" != "true" ]; then
    while ! pg_isready -h $DB_HOST -U $DB_USER; do
        echo "waiting until database ($DB_HOST) is ready..."
        sleep 5
    done
fi

# One-time execution to update any schema changes
php /ttrss/update.php --update-schema=force-yes

php /ttrss/update_daemon2.php
