#!/bin/bash

# Check if we are root
if [[ $EUID -ne 0 ]]; then
   return
fi

# Remove root and node user passwords
passwd -d root &> /dev/null
passwd -d node &> /dev/null

# Make root directory accessible (rwx) for the root group
chmod g+rwx /root/

# Make config files accessible for npm
chmod -R g+rwx /root/.config/