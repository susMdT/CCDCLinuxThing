#!/bin/sh

RHEL(){
    echo "export TERM=xterm" >> /etc/profile
}

DEBIAN(){
    echo Debian >/dev/null
    apt update -y
}

UBUNTU(){
    echo Ubuntu >/dev/null
    apt update -y
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
