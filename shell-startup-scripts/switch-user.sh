#!/bin/bash

# Avoid permissions issue with mounted volumes:
#   1. Detect the UID of the mounted directory
#   3. Switch to the user having the detected UID

# Check if the user should be switched
if [ "$SWITCH_USER" = "0" ]
  then
  return 0
fi

# Get current user's UID
CUR_UID=$(id -u)

# Extract the directory's UID
DIR_UID=$(stat -c '%u' $REPOSITORY_PATH)

# Check if UID of the current user is correct
if [ $CUR_UID -ne $DIR_UID ]
  then
  # After switching, do not switch the user again
  export SWITCH_USER='0'

  # Switch to the user with the directory's UID
  USER=$(getent passwd $DIR_UID | cut -d: -f1)
  usermod -aG root $USER
  if [ "$DEBUG_DOCKER_SETUP" = "1" ]; then echo "[switch-user.sh] Switching to user: $USER"; fi
  su --preserve-environment --shell=/bin/bash $USER

  # Exit after switching
  exit 0

fi
