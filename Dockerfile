FROM panamax/ruby

RUN apt-get install -y libsqlite3-dev

ADD . /var/app/panamax-api

WORKDIR /var/app/panamax-api
RUN bundle install
CMD bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed && bundle exec rails s
