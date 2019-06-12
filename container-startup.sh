# Check if container startup-scripts should be executed
if [ "$EXEC_CONTAINER_STARTUP_SCRIPTS" = "0" ]
  then
  return 0
fi

# Execute all container startup-scripts inside the "container-startup-scripts" folder
for script in /container-startup-scripts/*; do
  if [ "$DEBUG_DOCKER_SETUP" = "1" ]; then echo "Executing container startup script: $script"; fi
  source $script
done