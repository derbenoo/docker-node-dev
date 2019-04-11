# Avoid permissions issue with mounted volumes:
#   1. Detect the UID of the mounted directory
#   2. Create a user with the detected UID if none exists
#   3. Switch to the user having the detected UID

# Check if a cmd argument was provided
if [ $# -ne 1 ]
  then
  echo "Change the current user to the owner of the specified directory\nUSAGE: $0 [DIRPATH]"
  return 1
fi

# Check if the user should be switched
if [ "$SWITCH_USER" = "0" ]
  then
  return 0
fi

# Directory to get the UID from (provided as cmd argument)
DIRPATH=$1

# Get current user's UID
CUR_UID=$(id -u)

# Extract the directory's UID
DIR_UID=$(stat -c '%u' $DIRPATH)

# Check if UID needs to be changed
if [ $CUR_UID -ne $DIR_UID ]
  then

  # Check if a user with the directory's UID already exists
  getent passwd $DIR_UID > /dev/null
  if [ $? -ne 0 ]
    then
    # Create user and remove the password (name includes the UID to avoid collisions)
    useradd -u $DIR_UID node-$DIR_UID
    passwd -d node-$DIR_UID
  fi

  # Do not change the user again
  export SWITCH_USER='0'

  # Switch to the user with the directory's UID
  USER=$(getent passwd $DIR_UID | cut -d: -f1)
  usermod -aG root $USER
  su --preserve-environment --shell=/bin/bash $USER

  # Exit after switching
  exit 0

fi
