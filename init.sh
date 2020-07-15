#!/bin/sh

TTRSS_DIR=/ttrss

# Create needed directories if missing
for dir in cache lock feed-icons plugins.local themes.local; do
    mkdir -p $TTRSS_DIR/$dir
done

# Install (or update if pre-existing)
rsync -aP --delete \
    --exclude cache \
    --exclude lock \
    --exclude feed-icons \
    --exclude plugins.local \
    --exclude templates.local \
    --exclude themes.local \
    --exclude config.php \
    $SRC_DIR/ $TTRSS_DIR/

# Setup initial config.php based on envvars if missing
if [ ! -s $TTRSS_DIR/config.php ]; then
    SELF_URL_PATH=$(echo $SELF_URL_PATH | sed -e 's/[\/&]/\\&/g')

    sed -e "s/define('DB_HOST'.*/define('DB_HOST', '$DB_HOST');/" \
        -e "s/define('DB_USER'.*/define('DB_USER', '$DB_USER');/" \
        -e "s/define('DB_NAME'.*/define('DB_NAME', '$DB_NAME');/" \
        -e "s/define('DB_PASS'.*/define('DB_PASS', '$DB_PASS');/" \
        -e "s/define('DB_TYPE'.*/define('DB_TYPE', '$DB_TYPE');/" \
        -e "s/define('DB_PORT'.*/define('DB_PORT', $DB_PORT);/" \
        -e "s/define('SELF_URL_PATH'.*/define('SELF_URL_PATH','$SELF_URL_PATH');/" \
        <$TTRSS_DIR/config.php-dist >$TTRSS_DIR/config.php
fi
