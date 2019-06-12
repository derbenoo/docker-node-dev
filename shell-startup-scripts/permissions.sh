#!/bin/bash

# Make root directory accessible (rwx) for the root group
su -c "chmod g+rwx /root/"

# Make config files accessible for npm
su -c "chmod -R g+rwx /root/.config/"