FROM mhart/alpine-node:latest

ENV ELIXIR_VERSION 1.3.2

RUN apk --no-cache add git inotify-tools

# Install Erlang
RUN apk --no-cache add \
  erlang \
  erlang-asn1 \
  erlang-crypto \
  erlang-dev \
  erlang-erl-interface \
  erlang-eunit \
  erlang-inets \
  erlang-parsetools \
  erlang-public-key \
  erlang-sasl \
  erlang-ssl \
  erlang-syntax-tools \
  erlang-tools

# Install Elixir
ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin

RUN apk --no-cache add --virtual build-dependencies wget ca-certificates \
  && wget https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip \
  && mkdir -p /opt/elixir-${ELIXIR_VERSION}/ \
  && unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ \
  && rm -rf Precompiled.zip /etc/ssl \
  && apk del build-dependencies

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix hex.info

# Install Phoenix
RUN mix archive.install \
  https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

RUN mkdir -p /app
COPY . ./app
WORKDIR /app

# Install dependencies
RUN npm install
RUN mix deps.get

# Build production
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix phoenix.digest

# Start app
CMD ["mix", "phoenix.server"]
