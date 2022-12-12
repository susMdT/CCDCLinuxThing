#!/bin/sh

RHEL(){
    systemctl restart smb
}

DEBIAN(){
    systemctl restart smbd
}

UBUNTU(){
    DEBIAN
}

ALPINE(){
    service samba restart
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
