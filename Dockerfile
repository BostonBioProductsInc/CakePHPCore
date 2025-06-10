FROM php:8.2-apache

WORKDIR /var/www/html/

RUN apt-get update && \
    apt-get install --yes --force-yes \
    cron g++ gettext libicu-dev openssl \
    libc-client-dev libkrb5-dev  \
    libxml2-dev libfreetype6-dev \
    libgd-dev libmcrypt-dev bzip2 \
    libbz2-dev libtidy-dev libcurl4-openssl-dev \
    libz-dev libmemcached-dev libxslt-dev git-core libpq-dev \
    libzip4 libzip-dev libwebp-dev libmagickwand-dev libmagickcore-dev

# PHP Configuration
RUN docker-php-ext-install bcmath bz2 calendar dba exif gettext iconv intl soap tidy xsl zip && \
    docker-php-ext-install mysqli pgsql pdo pdo_mysql pdo_pgsql  && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-configure hash --with-mhash && \
    pecl install redis && docker-php-ext-enable redis && \
    pecl install mcrypt && docker-php-ext-enable mcrypt && \
    pecl install imagick && docker-php-ext-enable imagick

# log_errors = On
RUN echo 'log_errors=On' >> "$PHP_INI_DIR/php.ini-development"
RUN echo 'error_log=/dev/stderr' >> "$PHP_INI_DIR/php.ini-development"
RUN echo 'short_open_tag=On' >> "$PHP_INI_DIR/php.ini-development"
RUN echo 'memory_limit=4G' >> "$PHP_INI_DIR/php.ini-development"
RUN echo 'upload_max_filesize=100M' >> "$PHP_INI_DIR/php.ini-development"

# Use the default development configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

#set our application folder as an environment variable
ENV APP_HOME /var/www/html

#change the web_root to cakephp /var/www/html/webroot folder
RUN sed -i -e "s/html/html\/cake\/webroot/g" /etc/apache2/sites-enabled/000-default.conf

# enable apache module rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy source files
COPY --chown=www-data . $APP_HOME

# change ownership of our applications
RUN chown -R www-data:www-data $APP_HOME

# add executable flag to entrypoint script
RUN chmod +x entrypoint.sh

# Set the default command to run Apache2 in the foreground
CMD ["apache2-foreground"]

# Specify the entry point for the container
ENTRYPOINT ["./entrypoint.sh"] 

# END CAKE BUILD PROCESS #
