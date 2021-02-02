# Copyright (c) 2020 , Veepee
#
# Permission  to use,  copy, modify,  and/or distribute  this software  for any
# purpose  with or  without  fee is  hereby granted,  provided  that the  above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS  SOFTWARE INCLUDING ALL IMPLIED  WARRANTIES OF MERCHANTABILITY
# AND FITNESS.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL  DAMAGES OR ANY DAMAGES  WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER  TORTIOUS ACTION,  ARISING OUT  OF  OR IN  CONNECTION WITH  THE USE  OR
# PERFORMANCE OF THIS SOFTWARE.

FROM golang:1.15-alpine AS build-hub

ARG HUB_VERSION="2.14.2"

RUN apk add --no-cache --quiet \
      bash \
      build-base \
      ca-certificates \
      git \
      make

RUN mkdir -p /go/src/github.com/github && \
    cd /go/src/github.com/github && \
    git clone https://github.com/github/hub.git && \
    cd /go/src/github.com/github/hub && \
    git checkout v${HUB_VERSION} && \
    make

FROM golang:1.15-alpine AS build-lab

ARG LAB_VERSION="0.17.2"

RUN apk add --no-cache --quiet \
      build-base \
      ca-certificates \
      git \
      make

RUN mkdir -p /go/src/github.com/zaquestion && \
    cd /go/src/github.com/zaquestion && \
    git clone https://github.com/zaquestion/lab.git && \
    cd /go/src/github.com/zaquestion/lab && \
    git checkout v${LAB_VERSION} && \
    make

FROM alpine:3.13

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

RUN apk add --no-cache --quiet \
      git \
      openssh-client \
      glab@edge

COPY --from=build-hub  /go/src/github.com/github/hub/bin/hub \
                       /usr/bin/hub

COPY --from=build-lab  /go/src/github.com/zaquestion/lab/lab \
                       /usr/bin/lab

HEALTHCHECK NONE
# EOF
