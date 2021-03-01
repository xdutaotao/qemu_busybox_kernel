#!/bin/bash

[ `id -u` -ne "0" ] && {
    echo "Must run as root/sudo."
    exit 0
}

setup_br_tap(){
    nic="$1"
    br="br$2"
    tap="tap$2"

    ifconfig $br || brctl addbr $br
    ifconfig $tap || tunctl -u root -t $tap

    ifconfig $nic 0.0.0.0 up
    ifconfig $tap 0.0.0.0 up

    brctl addif $br $nic
    brctl addif $br $tap

    ip link set $br up

    dhclient -v $br
}

setup_br_tap "ens33" "0"
setup_br_tap "ens38" "1"

