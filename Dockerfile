FROM php:8.1-cli

LABEL org.opencontainers.image.source https://github.com/shoma/docker-php-dev

# https://getcomposer.org/doc/03-cli.md#environment-variables
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_NO_INTERACTION 1
ENV COMPOSER_VERSION 2.1.14
ENV XDEBUG_VERSION 3.1.2

RUN mkdir /composer
WORKDIR /composer
COPY composer.json /composer/composer.json

RUN apt-get update && apt-get install -y ${PHPIZE_DEPS} git unzip \
        && ln -s  /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
        && docker-php-ext-install -j "$(nproc)" pdo_mysql opcache \
        && (pecl install xdebug || pecl install xdebug-${XDEBUG_VERSION}) && docker-php-ext-enable xdebug \
        && php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" \
        && php composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
        && php -r "unlink('composer-setup.php');" \
        # tools
        && /usr/bin/composer --no-ansi install \
        && apt-get clean

# utilities
RUN apt-get install -y vim-tiny \
        && apt-get install -y locales \
        && echo 'en_US.UTF-8 UTF-8' >>  /etc/locale.gen \
        && locale-gen  \
        && update-locale \
        && apt-get clean

ENV PATH "${PATH}:/composer/vendor/bin"
ENV LANG en_US.UTF-8

# show infomation and verify
RUN php -v \
        && php -m \
        && composer --no-ansi --version \
        && /composer/vendor/bin/phpunit --version \
        && /composer/vendor/bin/phpstan --version \
        && /composer/vendor/bin/php-cs-fixer  --version \
        && /composer/vendor/bin/psysh --version

