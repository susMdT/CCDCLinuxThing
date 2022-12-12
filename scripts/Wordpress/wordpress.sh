# Ansible Vars
# IP => IP
# DB_HOST => host with the database

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

    mkdir /var/www/html/wordpress
    chmod -R 777 /var/www/html/wordpress
    mv /tmp/wp-config.php /var/www/html/wordpress/

    cd /var/www/html/wordpress 
    wp-cli core download --allow-root
    mysql -uroot -ppassword -e 'create database wordpress;' -h $DB_HOST
    wp-cli core install --url=http://$IP/ --admin_user=admin --admin_password=admin --title=Wordpress --admin_email=admin@localhost.com --allow-root
    chown -R apache /var/www/html/wordpress
    chgrp -R apache /var/www/html/wordpress
}

DEBIAN(){
    apt-get -qq update >/dev/null
    apt-get -qq install curl apache2 libapache2-mod-php7.4 php7.4 php7.4-common php7.4-curl php7.4-dev php7.4-gd php7.4-mysql sed -y

    sed 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/wordpress/' -i /etc/apache2/sites-enabled/000-default.conf
    systemctl restart apache2

    curl -L https://github.com/wp-cli/wp-cli/releases/download/v2.5.0/wp-cli-2.5.0.phar -o /usr/local/bin/wp-cli
    chmod +x /usr/local/bin/wp-cli

    mkdir /var/www/html/wordpress
    chmod -R 777 /var/www/html/wordpress
    mv /tmp/wp-config.php /var/www/html/wordpress/

    cd /var/www/html/wordpress 
    wp-cli core download --allow-root
    mysql -uroot -ppassword -e 'create database wordpress;' -h $DB_HOST
    wp-cli core install --url=http://$IP/ --admin_user=admin --admin_password=admin --title=Wordpress --admin_email=admin@localhost.com --allow-root
    chown -R www-data /var/www/html/wordpress
    chgrp -R www-data /var/www/html/wordpress
}

UBUNTU(){
    DEBIAN
}
ALPINE(){
    apk update >/dev/null
    apk add apache2 curl php7-common php7-session php7-iconv php7-json php7-gd php7-curl php7-xml php7-mysqli php7-imap php7-cgi fcgi php7-pdo php7-pdo_mysql php7-soap php7-xmlrpc php7-posix php7-mcrypt php7-gettext php7-ldap php7-ctype php7-dom php7-simplexml >/dev/null

    apk add php$phpverx-apache2

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



