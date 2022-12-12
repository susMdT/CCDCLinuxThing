#!/bin/sh

RHEL(){
    echo RHEL >> /etc/profile
}

DEBIAN(){
    echo Debian >/dev/null
}

UBUNTU(){
    echo Ubuntu >/dev/null
}

ALPINE(){
    echo Alpine >/dev/null
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

echo "" > /root/*_history