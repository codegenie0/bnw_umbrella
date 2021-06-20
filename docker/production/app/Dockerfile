FROM elixir:1.11-alpine as build

ENV REFRESHED_AT=2020-11-01 \
    # Set this so that CTRL+G works properly
    TERM=xterm

RUN apk add --no-cache build-base npm git python3

WORKDIR /app

RUN mix local.hex --force && \
  mix local.rebar --force

COPY config/ /app/config/
COPY mix.exs /app/
COPY mix.* /app/

COPY apps/bnw_dashboard/mix.exs /app/apps/bnw_dashboard/
COPY apps/bnw_dashboard_web/mix.exs /app/apps/bnw_dashboard_web/
COPY apps/accounts/mix.exs /app/apps/accounts/
COPY apps/borrowing_base/mix.exs /app/apps/borrowing_base/
COPY apps/component_applications/mix.exs /app/apps/component_applications/
COPY apps/customer_access/mix.exs /app/apps/customer_access/
COPY apps/tentative_ship/mix.exs /app/apps/tentative_ship/

ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . /app/

WORKDIR /app/apps/bnw_dashboard_web
RUN MIX_ENV=prod mix compile
RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

WORKDIR /app
RUN MIX_ENV=prod mix release

################################################################################

FROM elixir:1.10-alpine
RUN apk add --no-cache openssl ncurses-libs bash

EXPOSE 4000
ENV PORT=4000 \
  MIX_ENV=prod \
  SHELL=/bin/bash

WORKDIR /app

COPY --from=build app/_build/prod/rel/bnw_dashboard_umbrella .
COPY --from=build app/bin/ ./bin

CMD ["./bin/start"]
