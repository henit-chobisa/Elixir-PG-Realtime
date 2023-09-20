FROM gitpod/workspace-postgres

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

USER gitpod

RUN brew install elixir
RUN mix archive.install hex phx_new --force