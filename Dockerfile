FROM debian:9.12-slim

RUN apt-get update && apt-get -y upgrade

RUN apt-get install --fix-missing -y \
    wget \
    curl \
    dialog \
    bsdutils \
    unzip \
    git \
    gnupg \
    make \
    g++ \
    linux-libc-dev \
    catdoc \
    nano \
    poppler-utils \
    apt-transport-https \
    gpac \
    lsb-release

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php7.3.list
RUN apt-get update

RUN apt-get install -y nodejs php7.3-cli php7.3-mysql php7.3-xml php7.3-curl php7.3-gd php7.3-intl php7.3-zip php7.3-mbstring php7.3-sqlite php7.3-ldap php7.3-redis

RUN cd /tmp && git clone https://github.com/nrk/phpiredis.git
RUN cd /tmp/phpiredis && phpize && ./configure --enable-phpiredis
RUN cd /tmp/phpiredis && make && make install
RUN echo "extension=phpiredis.so" > /etc/php/7.3/mods-available/phpiredis.ini
RUN ln -s /etc/php/7.3/mods-available/phpiredis.ini /etc/php/7.3/cli/conf.d/phpiredis.ini
RUN ln -s /etc/php/7.3/mods-available/phpiredis.ini /etc/php/7.3/fpm/conf.d/phpiredis.ini
RUN rm -rf /tmp/phpiredis

RUN pecl install mcrypt-1.0.2

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin
RUN /usr/bin/composer.phar self-update

RUN wget -O /usr/bin/phpunit https://phar.phpunit.de/phpunit-5.phar
RUN chmod +x /usr/bin/phpunit

RUN cd /tmp && wget https://github.com/htacg/tidy-html5/releases/download/5.4.0/tidy-5.4.0-64bit.deb && dpkg -i tidy-5.4.0-64bit.deb

#
# Remove the packages that are no longer required after the package has been installed
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -q -y
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean -y -q
RUN DEBIAN_FRONTEND=noninteractive apt-get clean -y

# Remove all non-required information from the system to have the smallest
# image size as possible
# ftp://cgm_gebraucht%40used-forklifts.org:bZAo6dH1cyxhJpgJwO@ftp.strato.com/
RUN rm -rf /usr/share/doc/* /usr/share/man/?? /usr/share/man/??_* /usr/share/locale/* /var/cache/debconf/*-old /var/lib/apt/lists/* /tmp/*
