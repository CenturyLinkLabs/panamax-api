# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'coveralls'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start('rails') do
  add_filter 'panamax.rake'
end

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join('..', '..', '..', ENV['CIRCLE_ARTIFACTS'], 'coverage')
  SimpleCov.coverage_dir(dir)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.infer_spec_type_from_file_location!

  config.before(:each) do
    # Stub methods on Docker client
    allow(Docker::Container).to receive(:get).and_return({})
    allow(KMTS).to receive(:record)
    allow(KMTS).to receive(:alias)

    # Stub methods on PanamaxAgent::Journal::Client
    journal_client = double(:journal_client)
    allow(journal_client).to receive(:list_journal_entries).and_return(hash_from_fixture('journal'))

    allow(PanamaxAgent).to receive(:journal_client).and_return(journal_client)

    # Stub methods on Octokit::Client
    fake_github_object = double(:fake_github,
      repos: [],
      user: double(:user,
                   login: 'boom'
                  ),
      emails: [
        double(:email,
               primary: true,
               email: 'test@example.com'
              )
      ]
    )
    allow(Octokit::Client).to receive(:new).and_return(fake_github_object)

    #create dummy ssl certs dir
    FileUtils::mkdir_p('dummy_certs')
    allow(PanamaxApi).to receive(:ssl_certs_dir).and_return('dummy_certs/')
  end

  config.after(:each) do
    FileUtils.rm_rf('dummy_certs')
  end
end

def fixture_data(filename, path='support/fixtures')
  filename += '.json' if File.extname(filename).empty?
  file_path = File.expand_path(File.join(path, filename), __dir__)
  File.read(file_path).gsub(/\s+/, '')
end

def hash_from_fixture(filename, path='support/fixtures')
  JSON.parse(fixture_data(filename, path))
end
