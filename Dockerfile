FROM codelever/ubuntu-phoenix-docker:ubuntu-1804-erlang-22-0-7-elixir-1-9-1-otp-22-node-10-8-0

# install postgres client
RUN apt-get update && apt-get install -f -y postgresql-client

# install tzdata to prevent the prompt from stopping the install
# when cerbot tries to install this for us.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata 

# install certbot 
RUN apt-get update && \
apt-get install -f -y software-properties-common && \
add-apt-repository universe && \
add-apt-repository ppa:certbot/certbot && \
apt-get update && \
apt-get install -f -y certbot

# install application
ENV APP_ROOT /app
RUN mkdir -p ${APP_ROOT}

# install and compile dependencies
ENV MIX_ENV prod
WORKDIR ${APP_ROOT}
ADD mix.exs mix.exs
ADD mix.lock mix.lock
ADD config config
ADD mix.exs mix.exs
ADD config config
RUN mix deps.get --only ${MIX_ENV} \
 && mix deps.compile

# copy remaining application files
WORKDIR ${APP_ROOT}
ADD . .

# build application
WORKDIR ${APP_ROOT}
RUN mix compile

# compile the application assets
WORKDIR ${APP_ROOT}
RUN npm install --prefix ./assets && npm run deploy --prefix ./assets
WORKDIR ${APP_ROOT}
RUN mix phx.digest
