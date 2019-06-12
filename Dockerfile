# Node 10 is the current LTS version, supported until 01.04.2021 (https://nodejs.org/en/about/releases/)
FROM node:10-stretch

### USERS & PERMISSIONS ###
# Make sure we are root
USER root

# Remove root and node user passwords
RUN passwd -d root
RUN passwd -d node

### ENVIRONMENT VARIABLES ###
# Whether to print debug information
ENV DEBUG_DOCKER_SETUP=0

# Specify the absolute path to the repository mount point in an environment variable (so it can be changed). Defaults to "/app"
ENV REPOSITORY_PATH /app
WORKDIR ${REPOSITORY_PATH}

# Set the Node environment to "development"
ENV NODE_ENV=development

# Switch to the correct user to avoid permission issues
ENV SWITCH_USER=1

### SHELL SETUP ###
# Copy over shell-startup-scripts
COPY shell-startup-scripts /shell-startup-scripts
COPY shell-startup.sh /shell-startup.sh

# Execute all shell startup-scripts for each new bash
RUN echo 'source /shell-startup.sh' >> ~/.bashrc

### STARTUP ###
# Copy over container-startup-scripts folder
COPY container-startup-scripts /container-startup-scripts
COPY container-startup.sh /container-startup.sh

# Copy over entrypoint script
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
