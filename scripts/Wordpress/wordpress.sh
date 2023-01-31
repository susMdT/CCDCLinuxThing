#!/bin/sh

RHEL(){
    # php 7 and apache2
    yum install curl -y 
    yum -y remove php*

    yum install epel-release -y
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
    yum -y install yum-utils
    yum-config-manager --enable remi-php74
    yum update -y

    yum install php php-cli php-mysql php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json -y
    setsebool -P httpd_can_network_connect 1 # It's always fucking selinux

    systemctl restart httpd
    systemctl enable php-fpm
    systemctl start php-fpm
    systemctl restart httpd

    mkdir /var/www/html/wordpress/
    mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled
    echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
    echo "
<VirtualHost *:80>
    ServerName www.your_domain
    ServerAlias wordpress
    DocumentRoot /var/www/html/wordpress
</VirtualHost>
    " > /etc/httpd/sites-enabled/wordpress.conf

    curl -L https://github.com/wp-cli/wp-cli/releases/download/v2.5.0/wp-cli-2.5.0.phar -o /usr/local/bin/wp-cli
    chmod +x /usr/local/bin/wp-cli

    mv /tmp/wp-config.php /var/www/html/wordpress/

    cd /var/www/html/wordpress 
    /usr/local/bin/wp-cli core download --allow-root
    #mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e 'update mysql.user set plugin="" where user="root" and host="localhost";'
    mysql -e 'use mysql; alter user "root"@"localhost" identified by "password";'
    mysql -uroot -ppassword -e 'create database wordpress;' -h 127.0.0.1
    /usr/local/bin/wp-cli core install --url=http://localhost/ --admin_user=admin --admin_password=admin --title=Wordpress --admin_email=admin@localhost.com --allow-root
    chown -R apache /var/www/html/wordpress
    chgrp -R apache /var/www/html/wordpress
    chmod -R 777 /var/www/html/wordpress
}

DEBIAN(){
    apt-get -qq update >/dev/null
#    apt-get -qq install curl apache2 libapache2-mod-php7.4 php7.4 php7.4-common php7.4-curl php7.4-dev php7.4-gd php7.4-mysql sed -y
    apt-get -qq install apache2 php php-mysql
    mkdir /var/www/html/wordpress/
    sed 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/wordpress/' -i /etc/apache2/sites-enabled/000-default.conf
    systemctl restart apache2

    curl -L https://github.com/wp-cli/wp-cli/releases/download/v2.5.0/wp-cli-2.5.0.phar -o /usr/local/bin/wp-cli
    chmod +x /usr/local/bin/wp-cli

    mv /tmp/wp-config.php /var/www/html/wordpress/

    cd /var/www/html/wordpress 
    wp-cli core download --allow-root

    #mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e 'update mysql.user set plugin="" where user="root" and host="localhost";' 
    mysql -e 'use mysql; alter user "root"@"localhost" identified by "password";'
    mysql -uroot -ppassword -e 'create database wordpress;' -h 127.0.0.1
    wp-cli core install --url=http://localhost/ --admin_user=admin --admin_password=admin --title=Wordpress --admin_email=admin@localhost.com --allow-root
    chown -R www-data /var/www/html/wordpress
    chgrp -R www-data /var/www/html/wordpress
    chmod -R 777 /var/www/html/wordpress
}

UBUNTU(){
    DEBIAN
}
ALPINE(){
    wget http://dl-cdn.alpinelinux.org/alpine/v3.16/main/x86_64/libcrypto3-3.0.7-r0.apk
    apk add libcrypto3-3.0.7-r0.apk
    rm libcrypto3-3.0.7-r0.apk
    apk add --no-cache  --repository https://dl-cdn.alpinelinux.org/alpine/v3.13/community/ php7-apache2 php7-iconv php7 php7-json php7-cli php7-phar php7-mysqli php7-mysqlnd php7-pdo_mysql php7-common php7-curl apache2
    
    mkdir /var/www/localhost/wordpress
    sed 's/\/var\/www\/localhost\/htdocs/\/var\/www\/localhost\/wordpress/' -i /etc/apache2/httpd.conf
    service apache2 restart

    curl -L https://github.com/wp-cli/wp-cli/releases/download/v2.5.0/wp-cli-2.5.0.phar -o /usr/local/bin/wp-cli
    chmod +x /usr/local/bin/wp-cli

    chmod -R 777 /var/www/localhost/wordpress
    mv /tmp/wp-config.php /var/www/localhost/wordpress/

    cd /var/www/localhost/wordpress 
    /usr/local/bin/wp-cli core download --allow-root
    #mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e 'use mysql; alter user "root"@"localhost" identified by "password";'
    mysql -uroot -ppassword -e 'create database wordpress;' -h 127.0.0.1
    /usr/local/bin/wp-cli core install --url=http://localhost/ --admin_user=admin --admin_password=admin --title=Wordpress --admin_email=admin@localhost.com --allow-root
    chown -R apache /var/www/localhost/wordpress
    chgrp -R apache /var/www/localhost/wordpress
}


if command -v yum >/dev/null ; then
    yum check-update -y >/dev/null
    yum install curl apache2 php-gd php-soap php-intl php-mysqlnd php-pdo php-pecl-zip php-fpm php-opcache php-curl php-zip php-xmlrpc -y > /dev/null
    RHEL
elif command -v apt-get >/dev/null ; then
    if $(cat /etc/os-release | grep -qi Ubuntu); then
        UBUNTU
    else
        DEBIAN
    fi
elif command -v apk >/dev/null ; then
    ALPINE
fi



