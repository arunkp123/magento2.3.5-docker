FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR /var/www/
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_DOC_ROOT   /var/www/html

LABEL maintainer="arunkp123@live.in"

RUN apt-get update
RUN apt-get install -y python

RUN python -c 'print(" \033[32m Setting up linux tools ... \033[0m ")'
RUN apt-get install -y wget
RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN sudo -s

RUN python -c 'print(" \033[32m Installing Apache2.4 ... \033[0m ")'
RUN apt-get install -y apache2
RUN rm -rf ${APACHE_DOC_ROOT}/index.html
RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf


RUN python -c 'print(" \033[32m Instaling PHP7.3 ... \033[0m ")'
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt-get install -y php7.3-fpm
RUN apt-get install -y php7.3

RUN python -c 'print(" \033[32m Installing PHP7.3 extensions for Magento2.3.5 ... \033[0m ")'
RUN requirements="libpng++-dev libzip-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libfreetype6-dev libicu-dev libxslt1-dev unzip" \
    && apt-get update \
    && apt-get -y install gcc make autoconf libc-dev pkg-config \
    && apt-get -y install libmcrypt-dev
RUN apt-get -y install php-pear php7.3-curl php7.3-dev php7.3-gd php7.3-mbstring php7.3-zip php7.3-mysql php7.3-xml php7.3-fpm libapache2-mod-php7.3 php7.3-imagick php7.3-recode php7.3-tidy php7.3-xmlrpc php7.3-intl php7.3-bcmath php7.3-soap
RUN yes '' | pecl install mcrypt-1.0.3 \
    && echo 'extension=mcrypt.so' > /etc/php/7.3/mods-available/mcrypt.ini

# Install composer
RUN python -c 'print(" \033[32m Installing composer ...  \033[0m ")'
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
RUN composer

# Copy magento code base to DocumentRoot
RUN python -c 'print(" \033[32m Setting up Magento2.3.5 ...  \033[0m ")'
# Define working directory
WORKDIR ${WORK_DIR}

RUN cd ${WORK_DIR} \
    && wget https://api.arunkp.in/magento2-2.3.5-p1.tar.gz \
    && tar -xzf ./magento2-2.3.5-p1.tar.gz -C ${APACHE_DOC_ROOT} \
    && cd ${APACHE_DOC_ROOT} \
    && mv magento2-2.3.5-p1/* ${APACHE_DOC_ROOT}
RUN cd ${APACHE_DOC_ROOT} \
    && composer install

RUN cd $APACHE_DOC_ROOT \
    && find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +\
    && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +\
    && chown -R :www-data .\
    && chmod u+x bin/magento

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D",  "FOREGROUND"]
