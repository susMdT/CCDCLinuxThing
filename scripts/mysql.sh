#!/bin/sh

RHEL(){
    yum install mysql mariadb-server -y
    systemctl restart mariadb
    mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e "grant all on *.* to 'root'@'%';"
    systemctl restart mariadb
}

DEBIAN(){
    apt install mariadb-server -y
    sed -E 's/=.*127.0.0.1/= 0.0.0.0/' -i /etc/mysql/mariadb.conf.d/50-server.cnf
    mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e "grant all on *.* to 'root'@'%';"
    systemctl restart mariadb
}

UBUNTU(){
    apt install mysql-server -y
    sed -E 's/=.*127.0.0.1/= 0.0.0.0/' -i /etc/mysql/mysql.conf.d/mysqld.cnf
    mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e "grant all on *.* to 'root'@'%';"
    systemctl restart mysql
}

ALPINE(){
    apk add mariadb mysql mysql-client
    /etc/init.d/mariadb setup
    service mariadb restart
    sed 's/#bind-/bind-/' -i /etc/my.cnf.d/mariadb-server.cnf
    sed 's/skip-networking/#skip-networking/' -i /etc/my.cnf.d/mariadb-server.cnf
    mysql -e 'create user "root"@"%" identified by "password";'
    mysql -e "grant all on *.* to 'root'@'%';"
    rc-update add mariadb default
    service mariadb restart
}


if command -v yum >/dev/null ; then
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
