#!/bin/bash

# Execute all container startup scripts
source /container-startup.sh

# idle (developer attaches via interactive shell)
if [ "$DEBUG_DOCKER_SETUP" = "1" ]; then echo "Entering idling mode..."; fi

tail -f /dev/null