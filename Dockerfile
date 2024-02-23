ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_GUID=109

FROM debian:bookworm as downloader
ARG DEBIAN_FRONTEND
ARG RUNNER_VERSION

RUN apt-get update && apt-get install -y curl &&  \
    mkdir /dist && cd /dist && \
    curl -o actions-runner-linux-x64-"${RUNNER_VERSION}".tar.gz -L \
    https://github.com/actions/runner/releases/download/v"${RUNNER_VERSION}"/actions-runner-linux-x64-"${RUNNER_VERSION}".tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

FROM debian:bookworm
ARG DEBIAN_FRONTEND
ARG DOCKER_GUID
ARG RUNNER_VERSION

ENV PATH="$PATH:/home/docker/actions-runner/bin"

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl jq && \
    groupadd -g "${DOCKER_GUID}" docker && useradd -m docker -g docker
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx
COPY --from=downloader /dist/bin/installdependencies.sh /home/docker/dist/bin/installdependencies.sh

WORKDIR /home/docker/actions-runner
RUN /home/docker/dist/bin/installdependencies.sh && chown docker:docker /home/docker/actions-runner

USER docker
COPY entrypoint.sh /home/docker/dist/entrypoint.sh
ENTRYPOINT ["/home/docker/dist/entrypoint.sh"]