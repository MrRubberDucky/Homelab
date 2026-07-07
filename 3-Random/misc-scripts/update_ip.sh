#!/bin/bash
# All this script does is update old dynamic IP with new one from a dyndns provider.
# yoinked it off stackoverflow. Requires bind9-utils to work properly
HOSTNAME=dyndns_here

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

new_ip=$(host $HOSTNAME | head -n1 | cut -f4 -d ' ')
old_ip=$(/usr/sbin/ufw status | grep $HOSTNAME | head -n1 | tr -s ' ' | cut -f3 -d ' ')

if [ "$new_ip" = "$old_ip" ] ; then
    echo IP address has not changed
else
    if [ -n "$old_ip" ] ; then
       /usr/sbin/ufw delete allow from $old_ip/32 to any port 22 proto tcp
       /usr/sbin/ufw delete allow from $old_ip/32 to any port 51820 proto udp
    fi
    /usr/sbin/ufw insert 1 allow from $new_ip/32 to any port 22 proto tcp
    /usr/sbin/ufw insert 3 allow from $new_ip/32 to any port 51820 proto udp
    echo ufw was updated
fi
