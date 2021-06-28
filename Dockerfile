FROM php:8-fpm-alpine3.13
LABEL maintainer "Thomas Ingvarsson <ingvarsson.thomas@gmail.com>"

ARG BUILD_DATE
ARG VCS_REF
ARG TTRSS_VERSION

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="tingvarsson/ttrss"
LABEL org.label-schema.description="Tiny Tiny RSS image based on Alpine Linux"
LABEL org.label-schema.vcs-url="https://github.com/tingvarsson-docker/docker.ttrss"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.version=$TTRSS_VERSION

# Install php extensions and needed dependencies
RUN apk add --no-cache \
    freetype \
    icu \
    libjpeg-turbo \
    libpng \
    libwebp \
    libxpm \
    postgresql \
    rsync \
    zlib \
    && apk add --no-cache --virtual=php-build-dependencies \
    freetype-dev \
    icu-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    postgresql-dev \
    && docker-php-ext-configure gd \
    --enable-gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-xpm \
    && docker-php-ext-install \
    gd \
    intl \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && apk del php-build-dependencies

# Add TTRSS source to image
ENV SRC_DIR=/src/ttrss

ARG TTRSS_URL=https://git.tt-rss.org/fox/tt-rss/archive/$TTRSS_VERSION.tar.gz

RUN apk add --no-cache --virtual=build-dependencies \
    curl \
    tar \
    && mkdir -p $SRC_DIR \
    && curl -s $TTRSS_URL | tar vxz -C $SRC_DIR --strip-components=1 \
    && apk del build-dependencies

# Prepare bootstrap and target directory for non-root users
ENV BOOTSTRAP_DIR=/bootstrap
ENV TTRSS_DIR=/ttrss
RUN mkdir -p $BOOTSTRAP_DIR $TTRSS_DIR \
    && chmod a+rwx $BOOTSTRAP_DIR $TTRSS_DIR
VOLUME $TTRSS_DIR

# Configuration options
# Used by start.sh and update.sh
ENV ENABLE_BOOTSTRAP=false \
    SKIP_DB_CHECK=false

# TTRSS Configuration
ENV TTRSS_DB_TYPE="pgsql" \
    TTRSS_DB_HOST="localhost" \
    TTRSS_DB_PORT="5432" \
    TTRSS_DB_USER="ttrss" \
    TTRSS_DB_PASS="ttrssPass" \
    TTRSS_DB_NAME="ttrss" \
    TTRSS_SELF_URL_PATH="http://localhost" \
    TTRSS_PHP_EXECUTABLE=/usr/local/bin/php

ADD init.sh /
ADD start.sh /
ADD update.sh /

CMD ["/start.sh"]
