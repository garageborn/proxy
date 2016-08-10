FROM ruby:2.3.1-slim

# install dependencies
RUN apt-get update -qq && apt-get install --fix-missing -y build-essential git-core

# build proxy
ENV PROXY /proxy
RUN mkdir $PROXY
COPY . $PROXY
WORKDIR $PROXY

RUN ./bin/bundle install --jobs 10 --without development test
