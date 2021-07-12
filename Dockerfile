FROM ruby:2.7.4-alpine3.13

WORKDIR /app

COPY . .

ENV GITHUB_TOKEN=

RUN apk update && apk upgrade && apk --update add \
    build-base tzdata && \
    echo 'gem: --no-document' > /etc/gemrc && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle config set deployment 'true' && \
    bundle install --jobs=2 && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    apk del build-base

# this starts the clockwork process as a background daemon and server in the foreground
CMD YESTERDAYS_DEPLOYER_FILE='/app/yesterdays_deployer.json' bundle exec clockworkd -c clock.rb start && YESTERDAYS_DEPLOYER_FILE='yesterdays_deployer.json' bundle exec rackup --host 0.0.0.0 -p 5000
