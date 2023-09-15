FROM gitpod/workspace-postgres

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

USER gitpod

RUN brew install elixir
RUN mix archive.install hex phx_new --force

# RUN apt-get update \
#     && apt-get install erlang -y \
#     && apt-get install elixir -y \
#     && apt-get install inotify-tools -y \
#     && mix local.hex --force \
#     && mix local.rebar --force \
#     && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Set wal_level to logical