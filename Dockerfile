FROM ruby:2.3.1-slim

ENV PROXY /proxy
RUN mkdir $PROXY
COPY . $PROXY
WORKDIR $PROXY

RUN ./bin/bundle install --jobs 10 --without development test
