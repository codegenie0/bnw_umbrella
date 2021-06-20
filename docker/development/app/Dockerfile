FROM elixir:1.11-alpine

ENV REFRESHED_AT=2020-11-01 \
    # Set this so that CTRL+G works properly
    TERM=xterm

# Install NPM
RUN mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    apk update && \
    apk --no-cache --update add git make g++ wget curl inotify-tools nodejs nodejs-npm && \
    npm install npm -g --no-progress && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/*

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex \
    HOME=/opt/app


# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.5.3 --force

WORKDIR /opt/app
ADD . /opt/app

EXPOSE 4000

CMD ["mix", "phx.server"]
