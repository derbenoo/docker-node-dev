# Docker image for Node.js development

Solve common issues when developing node applications inside a Docker container.

## Quick Start

Use one of the ways documented below to start a development container. Each one assumes that you are in the directory which you want to mount inside the container.

#### One-liner

```
$ docker run -it --rm --entrypoint=/bin/bash --mount type=bind,source="$(pwd)"/,target=/app derbenoo/node-dev
```

#### Docker-compose

```yml
# docker-compose.yml
version: "3.2"
services:
  node-dev:
    container_name: node-dev
    hostname: node-dev
    image: derbenoo/node-dev:latest
    volumes:
      - type: bind
        source: .
        target: /app/
```

Run `docker-compose up -d` to start the container and `docker exec -it node-dev bash` to attach.

#### Manual

Build, run and attach an interactive shell to the docker container:

```
$ docker build -t node-dev:latest .
$ docker run -d --name node-dev --mount type=bind,source="$(pwd)"/,target=/app node-dev
$ docker exec -it node-dev bash
```

## Features

The following modifications are applied to the Node base image:

- Use Node 10 as base image
- Mount repository to `/app`
- Set the node environment to `development`
- Execute scripts on container startup
- Execute scripts when a new bash is spawned
- Add npm package executables to `$PATH`
- Activate tab completion for npm
- Use the same UID as the mounted volume's owner
- Load bash aliases from `~/bash_aliases` if the file exists
- Let the container idle by default

### Use Node 10 as base image

```
FROM node:10-stretch
```

Node 10 is the current LTS (long-term support) version and supported until **01.04.2021**. See the release schedule here: https://nodejs.org/en/about/releases/

### Mount repository to `/app`

```
ENV REPOSITORY_PATH /app
```

To avoid re-building the docker image each time a source-code change was made, it is common practice to mount the entire repository inside the container. The `/app` directory is configured to be the mount point for the repository by default. This can be changed by setting the `REPOSITORY_PATH` environment variable:

```
$ docker run --env REPOSITORY_PATH=/repo-path -it --rm --entrypoint=/bin/bash --mount type=bind,source="$(pwd)"/,target=/app derbenoo/node-dev
```

### Set the node environment to `development`

```
ENV NODE_ENV=development
```

`NODE_ENV` is an environment variable that specifies the environment in which an application is running such as development, staging or production. It is a convention used by many packages.

### Execute scripts on container startup

```
ENTRYPOINT ["bash", "/entrypoint.sh"]

# entrypoint.sh
source /container-startup.sh
```

Commands executed via `RUN` inside a Dockerfile can only introduce changes to the files of the final docker image but not to the container's runtime (e.g., starting a daemon process). It is therefore often useful to execute scripts when the container is started. This is done via an `entrypoint.sh` script. An entrypoint script is already provided by this docker image, which automatically checks the `/container-startup-scripts` folder and executes all scripts it encounters inside that folder in alphabetical order. You can therefore place all scripts you want to be executed at startup inside the `/container-startup-scripts` folder. This behavior can be deactivated by setting the `EXEC_CONTAINER_STARTUP_SCRIPTS` to `0`.

### Execute scripts when a new bash is spawned

```
RUN echo 'source /shell-startup.sh' >> ~/.bashrc
```

It is possible to execute a script whenever a new bash is spawned by placing the script inside the `/shell-startup-scripts/` directory. This behavior can be deactivated by setting the `EXEC_SHELL_STARTUP_SCRIPTS` environment variable to `0`. The following scripts are executed by default:
- Load bash aliases
- Activate tab completion for npm
- Switch to the user with the same UID as the mounted volume's owner  


### Activate tab completion for npm

```
shell-startup-scripts/npm-completion.sh
```

Enables tab-completion in all npm commands: https://docs.npmjs.com/cli/completion.html

### Add npm package executables to `$PATH`

```
RUN echo 'export PATH="$PATH:/app/node_modules/.bin"' >> ~/.bashrc
```

Note that the `node_modules/.bin` directory is appended to the end of the `$PATH` variable so that it does not overwrite any system commands.

### Let the container idle by default

```
# entrypoint.sh
tail -f /dev/null
```

The container will idle by default such that a developer can attach to it with a shell: `docker exec -it app /bin/bash`.

You can override this entrypoint using `docker run --entrypoint=/bin/bash` or the [entrypoint option](https://docs.docker.com/compose/compose-file/#entrypoint) inside a docker-compose file.

### Use the same UID as the mounted volume's owner

```
ENV SWITCH_USER=1
container-startup-scripts/create-user-for-repo-uid.sh
shell-startup-scripts/switch-user.sh
```

File permissions are a frequent issue when mounting your repository inside a development container. If you are developing as the `root` user inside the container, all files created will be owned by root on the host machine as well, giving you lots of permission issues when trying to modify those files on the host as a normal system user. This problem occurs whenever the UID of the host system's user does not match the UID of the container's user.

Therefore, the `switch-user.sh` script makes sure that you are logged in with a user having the same UID as the host system user who owns the repository files. If no user with such a UID exists, the script creates one.

##### Switching back to root

You can switch back to the `root` user inside the container at anytime:

```
$ su root
```

No password is required as the passwords for all users are removed inside the container.

##### Disable user switching

If you want to disable this behavior, you can simply set the `SWITCH_USER` environment variable to `0`.

Docker run:

```
$ docker run --env SWITCH_USER=0 -it --rm --entrypoint=/bin/bash --mount type=bind,source="$(pwd)"/,target=/app derbenoo/node-dev
```

Docker-compose:

```yml
# docker-compose.yml
version: "3.2"
services:
  node-dev:
    container_name: node-dev
    hostname: node-dev
    image: derbenoo/node-dev:latest
    volumes:
      - type: bind
        source: .
        target: /app/
    environment:
      - SWITCH_USER=0
```

### Load bash aliases from `~/bash_aliases`

Bash aliases can be defined in a separate file called `~/.bash_aliases`. An example file could look like this:

```sh
# ~/.bash_aliases

# add some ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
```
