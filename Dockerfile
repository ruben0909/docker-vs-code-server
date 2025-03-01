FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ruben0909"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    sudo && \
  echo "**** install vs-code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/microsoft/vscode/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/vs-code-server && \
  curl -o \
    /tmp/vs-code-server.tar.gz -L \
    "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64" && \
  tar xf /tmp/vs-code-server.tar.gz -C \
    /app/vs-code-server && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 8443
