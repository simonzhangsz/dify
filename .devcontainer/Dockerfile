FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

# Configure git to handle network issues better
RUN git config --global http.version HTTP/1.1 && \
    git config --global http.postBuffer 524288000

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install libgmp-dev libmpfr-dev libmpc-dev
