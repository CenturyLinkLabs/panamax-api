source 'https://rubygems.org'

gem 'rails', '4.1.0'
gem 'sqlite3'
gem 'faraday_middleware'
gem 'jbuilder', '~> 2.0'
gem 'docker-api', '1.9.0', require: 'docker'
gem 'active_model_serializers'
gem 'octokit', '~> 3.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :test, :development do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :test do
  gem 'coveralls'
  gem 'database_cleaner'
end
