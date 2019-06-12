#!/bin/bash

# Extract the directory's UID
DIR_UID=$(stat -c '%u' $REPOSITORY_PATH)

# Check if a user with the directory's UID already exists
getent passwd $DIR_UID > /dev/null
if [ $? -ne 0 ]
  then
  # Create user and remove the password (name includes the UID to avoid collisions)
  useradd -u $DIR_UID node-$DIR_UID
  passwd -d node-$DIR_UID
fi