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
    $SRC_DIR/ $TTRSS_DIR/

# Setup empty default as TTRSS still expects one to exist
if [ ! -s $TTRSS_DIR/config.php ]; then
    cp $TTRSS_DIR/config.php-dist $TTRSS_DIR/config.php
fi
