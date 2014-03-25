#!/bin/bash

cd /var/app/panamax-api
bundle install --gemfile=/var/app/panamax-api/Gemfile
bundle exec rake db:setup
bundle exec rails s