FROM 74.201.240.198:5000/ruby:alpha

ADD . /var/app/panamax-api

EXPOSE 3000
ENV RAILS_ENV production

WORKDIR /var/app/panamax-api
RUN bundle
CMD bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed && bundle exec rake panamax:templates:unload && bundle exec rake panamax:templates:load && bundle exec rails s -e production
