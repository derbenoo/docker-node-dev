# Node 10 is the current LTS version, supported until 01.04.2021 (https://nodejs.org/en/about/releases/)
FROM node:10-stretch

# Make sure we are root
USER root

# Remove root and node user passwords
RUN passwd -d root
RUN passwd -d node

# Make root directory accessible (rwx) for the root group
RUN chmod g+rwx /root/

# Set the working directory to the main repository (mounted under /app)
WORKDIR /app

# Signal debian that we are non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Set the Node environment to "development"
ENV NODE_ENV=development

# Load bash aliases if ~/.bash_aliases file exists
RUN echo 'if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi' >> ~/.bashrc

# Activate npm autocompletion
RUN npm completion >> ~/.bashrc

# Add .bin folder of the project to the PATH env variable
RUN echo 'export PATH="/app/node_modules/.bin:$PATH"' >> ~/.bashrc

# Make config files accessible (e.g. for npm)
RUN echo "chmod -R g+rwx /root/.config/ &> /dev/null" >> ~/.bashrc

# Switch to the correct user to avoid permission issues
COPY switch-user.sh /
ENV SWITCH_USER=1
RUN echo "source /switch-user.sh /app/" >> ~/.bashrc

# Entrypoint: idle (dev attach via interactive shell)
ENTRYPOINT tail -f /dev/null
