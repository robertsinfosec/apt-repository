FROM mcr.microsoft.com/devcontainers/base:debian

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    less \
    bash-completion \
    tree \
    ripgrep \
    build-essential \
    make \
    man-db \
    manpages \
    manpages-dev \
    groff \
    help2man \
    dpkg-dev \
    debhelper \
    devscripts \
    fakeroot \
    lintian \
    reprepro \
    gnupg \
    gpg-agent \
    apt-utils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/cache/man && \
    chmod 755 /var/cache/man

SHELL ["/bin/bash", "-c"]

RUN echo "if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi" >> /home/vscode/.bashrc

USER vscode
WORKDIR /workspaces
