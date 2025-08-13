#!/bin/bash

set -e
# set -x

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: must be run as root."
    exit 1
fi

if [ -d "/etc/update-motd.d" ]; then
    chmod -x /etc/update-motd.d/*
    chmod +x /etc/update-motd.d/98-reboot-required
else
    echo "Error: /etc/update-motd.d directory not found."
    exit 1
fi

echo "Finished."
