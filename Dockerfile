# Tiny Tiny RSS
#
# Version latest

FROM alpine
LABEL maintainer "Thomas Ingvarsson <ingvarsson.thomas@gmail.com>"

RUN apk add --no-cache \
      supervisor \
      nginx \
      php7 \
      php7-apcu \
      php7-curl \
      php7-dom \
      php7-fileinfo \
      php7-fpm \
      php7-gd \
      php7-iconv \
      php7-intl \
      php7-json \
      php7-mbstring \
      php7-mysqli \
      php7-mysqlnd \
      php7-opcache \
      php7-pcntl \
      php7-pdo_mysql \
      php7-pdo_pgsql \
      php7-pgsql \
      php7-posix \
      php7-session \
      php7-zlib \
    && apk add --no-cache --virtual=build-dependencies \
      curl \
      tar \
    && mkdir /run/nginx \
    && curl -o /tmp/ttrss.tar.gz -L "https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz" \
    && mkdir -p /var/www/html/ \
    && tar xf /tmp/ttrss.tar.gz -C /var/www/html/ --strip-components=1 \
    && rm -rf /tmp/ttrss.tar.gz \
    && apk del build-dependencies

RUN adduser -u 82 -D -S -G www-data www-data \
    && sed -i s/'user = nobody'/'user = www-data'/g /etc/php7/php-fpm.d/www.conf \
    && sed -i s/'group = nobody'/'group = www-data'/g /etc/php7/php-fpm.d/www.conf \
    && chown -R www-data:www-data /var/www/html/

VOLUME /ttrss

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf
COPY start.sh /start.sh

EXPOSE 80 443

CMD ["/start.sh"]