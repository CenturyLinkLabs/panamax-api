source 'https://rubygems.org'

gem 'rails', '4.0.4'
gem 'sqlite3'
gem 'faraday_middleware'
gem 'hashie'
gem 'jbuilder', '~> 1.2'
gem 'docker-api', '1.9.0', require: 'docker'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :test, :development do
  gem 'rspec-rails'
  gem 'shoulda'
end

group :test do
  gem 'coveralls'
  gem 'database_cleaner'
end
