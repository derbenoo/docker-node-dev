# Docker image for Node.js development

Solve common issues when developing node applications inside a Docker container.

## :running: Quick Start

#### One-liner

```
docker run -it --rm --mount type=bind,source="$(pwd)"/,target=/app derbenoo/node-dev
```

#### Docker-compose

```yml
# docker-compose.yml
services:
  node-dev:
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

## :tada: Features

The following modifications are applied to the Node base image:

- Use Node 10 as base image
- Mount repository to `/app`
- Set the node environment to `development`
- Activate tab completion for npm
- Add npm package executables to `$PATH`
- Use the same UID as the mounted volume's owner
- Let the container idle

### Use Node 10 as base image

```
FROM node:10-stretch
```

Node 10 is the current LTS (long-term support) version and supported until **01.04.2021**. See the release schedule here: https://nodejs.org/en/about/releases/

### Mount repository to `/app`

```
WORKDIR /app
```

To avoid re-building the docker image each time a source-code change was made, it is common practice to mount the entire repository inside the container. The `/app` directory is configured to be the mount point for the repository.

### Set the node environment to `development`

```
ENV NODE_ENV=development
```

`NODE_ENV` is an environment variable that specifies the environment in which an application is running such as development, staging or production. It is a convention used by many packages.

### Activate tab completion for npm

```
RUN npm completion >> ~/.bashrc
```

Enables tab-completion in all npm commands: https://docs.npmjs.com/cli/completion.html

### Add npm package executables to `$PATH`

```
RUN echo 'export PATH="$PATH:/app/node_modules/.bin"' >> ~/.bashrc
```

Note that the `node_modules/.bin` directory is appended to the end of the `$PATH` list so that it does not overwrite system commands.

### Use the same UID as the mounted volume's owner

```
ENV SWITCH_USER=1
RUN echo "source /switch-user.sh /app/" >> ~/.bashrc
```

- Remove passwords for the `node` and `root` users.
- Use the same UID as the mounted volume to avoid permission issues

**If you want to disable this feature**: Do not switch user

`su root`

Set `SWITCH_USER=0` in a docker-compose file or using `-e` to prevent switching.

### Let the container idle

```
ENTRYPOINT tail -f /dev/null
```

The container will idle such that a developer can attach to it with a shell: `docker exec -it app /bin/bash`.
