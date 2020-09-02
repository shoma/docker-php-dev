FROM php:7.4-cli

# https://getcomposer.org/doc/03-cli.md#environment-variables
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 2.0.0-alpha2
ENV COMPOSER_NO_INTERACTION 1

RUN apt-get update && apt-get install -y ${PHPIZE_DEPS} git unzip \
        && docker-php-ext-install -j "$(nproc)" pdo_mysql opcache \
        && (pecl install xdebug || pecl install xdebug-2.5.5) && docker-php-ext-enable xdebug \
        && mkdir /composer \
        && php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" \
        && php composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
        && php -r "unlink('composer-setup.php');" \
        && composer --no-ansi global require --prefer-dist \
            phpunit/phpunit \
            phpstan/phpstan \
            friendsofphp/php-cs-fixer \
            psy/psysh \
        && apt-get clean \
        && export PATH="${PATH}:/composer/vendor/bin"

# show infomation and verify
RUN php -v \
        && php -m \
        && composer --no-ansi --version \
        && /composer/vendor/bin/phpunit --version \
        && /composer/vendor/bin/phpstan --version \
        && /composer/vendor/bin/php-cs-fixer  --version \
        && /composer/vendor/bin/psysh --version

ENV PATH "/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
