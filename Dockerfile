FROM mathosk/rpi-ruby-2.6.5-ubuntu-aarch64:latest

MAINTAINER Matho "martin.markech@matho.sk"

RUN apt-get update && apt-get install -y \
    curl \
    vim \
    git \
    build-essential \
    libgmp-dev \
    libpq-dev \
#    postgresql-client \
    locales \
    nginx \
    cron \
    bash \
    imagemagick \
    python \
    nodejs \
    npm

RUN npm install --global yarn

WORKDIR /app

ARG BUNDLE_CODE__MATHO__SK
ARG RAILS_ENV

ADD ./Gemfile ./Gemfile
ADD ./Gemfile.lock ./Gemfile.lock

RUN gem install bundler -v '> 2'
RUN bundle install --deployment --clean --path vendor/bundle --without development test --jobs 8

ADD . .

# Set Nginx config
ADD config/etc/nginx/conf.d/nginx.docker.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default

ADD .env.example .env.production

RUN ASSET_PRECOMPILE_MODE=1 bundle exec rake assets:precompile RAILS_ENV=production --trace

RUN echo $(date) > BUILD_DATE.txt

EXPOSE 80

CMD bin/run.docker.sh


