#!/bin/sh

RHEL(){
    yum install samba samba-client -y
    mkdir /opt/work
    systemctl restart smb
}

DEBIAN(){
    DEBIAN_FRONTEND=noninteractive  apt install -y  samba samba-client
    mkdir /opt/work
    systemctl restart smbd
}

UBUNTU(){
    DEBIAN
}

ALPINE(){
    apk add samba samba-client
    mkdir /opt/work
    service samba restart
    rc-update add samba default
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
