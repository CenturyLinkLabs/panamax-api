FROM centurylink/panamax-ruby-base:0.4.0

CMD bundle exec rake db:create && \
  bundle exec rake db:migrate && \
  bundle exec rake db:seed && \
  bundle exec rake panamax:templates:unload && \
  bundle exec rake panamax:templates:load && \
  bundle exec rake panamax:job_templates:unload && \
  bundle exec rake panamax:job_templates:load && \
  bundle exec rails s
