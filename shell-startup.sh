#!/bin/sh

# Check if shell startup-scripts should be executed
if [ "$EXEC_SHELL_STARTUP_SCRIPTS" = "0" ]
  then
    if [ "$DEBUG_DOCKER_SETUP" = "1" ]; then echo "[shell-startup.sh] Skipping the execution of shell startup scripts"; fi
  return 0
fi

# Execute all shell startup-scripts inside the "shell-startup-scripts" folder
for script in /shell-startup-scripts/*; do
  if [ "$DEBUG_DOCKER_SETUP" = "1" ]; then echo "[shell-startup.sh] Executing shell startup script: $script"; fi
  source $script
done