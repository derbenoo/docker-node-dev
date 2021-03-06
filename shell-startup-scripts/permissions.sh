#!/bin/bash

# Check if we are root
if [[ $EUID -ne 0 ]]; then
   return
fi

# Remove root and node user passwords
if [ "$DOCKER_RM_USER_PWDS" = "1" ]
  then
    passwd -d root &> /dev/null
    passwd -d node &> /dev/null
    if [ "$DEBUG_DOCKER_SETUP" = "1" ]; then echo "[permissions.sh] Removed passwords for user accounts"; fi
fi

# Make root directory accessible (rwx) for the root group
chmod g+rwx /root/

# Make config files accessible for npm
chmod -R g+rwx /root/.config/