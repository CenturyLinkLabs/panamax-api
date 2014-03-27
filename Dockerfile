FROM panamax/ruby

RUN apt-get install -y libsqlite3-dev

ADD . /var/app/panamax-api
RUN chmod +x /var/app/panamax-api/bin/start.sh

WORKDIR /var/app/panamax-api
RUN bundle install
CMD bundle exec rake db:setup && bundle exec rails s
