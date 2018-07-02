FROM php:7.2-cli-stretch

RUN apt-get update && apt-get install -y ${PHPIZE_DEPS} \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install opcache \
    && (pecl install xdebug || pecl install xdebug-2.5.5) && docker-php-ext-enable xdebug \
    && php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && apt-get clean
