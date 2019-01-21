FROM php:7.2-fpm-alpine

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS make autoconf rabbitmq-c rabbitmq-c-dev \
    && pecl install amqp \
    && docker-php-ext-enable amqp

RUN apk add gosu --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    && addgroup bar \
    && adduser -D -h /home -s /bin/sh -G bar foo \
    && mkdir -p /srv/app

WORKDIR /srv/app

ADD entrypoint.sh /entrypoint

ENTRYPOINT ["/entrypoint"]
