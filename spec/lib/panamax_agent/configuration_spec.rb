require 'spec_helper'

describe PanamaxAgent::Configuration do

  subject { Class.new { extend PanamaxAgent::Configuration } }

  describe 'exposed attribes' do
    PanamaxAgent::Configuration::VALID_OPTIONS_KEYS.each do |key|
      it { should respond_to key.to_sym }
    end
  end

  describe 'default values' do
    its(:adapter) { should eql PanamaxAgent::Configuration::DEFAULT_ADAPTER }
    its(:registry_api_url) { should eql PanamaxAgent::Configuration::DEFAULT_REGISTRY_API_URL }
    its(:registry_api_version) { should eql PanamaxAgent::Configuration::DEFAULT_REGISTRY_API_VERSION }
    its(:journal_api_url) { should eql PanamaxAgent::Configuration::DEFAULT_JOURNAL_API_URL }
    its(:stevedore_api_url) { should eql PanamaxAgent::Configuration::DEFAULT_STEVEDORE_API_URL }
    its(:mailchimp_api_url) { should eql PanamaxAgent::Configuration::DEFAULT_MAILCHIMP_API_URL }
    its(:mailchimp_user) { should eql PanamaxAgent::Configuration::DEFAULT_MAILCHIMP_USER }
    its(:mailchimp_id) { should eql PanamaxAgent::Configuration::DEFAULT_MAILCHIMP_ID }
    its(:mailchimp_group_id) { should eql PanamaxAgent::Configuration::DEFAULT_MAILCHIMP_GROUP_ID }
    its(:open_timeout) { should eql PanamaxAgent::Configuration::DEFAULT_OPEN_TIMEOUT }
    its(:read_timeout) { should eql PanamaxAgent::Configuration::DEFAULT_READ_TIMEOUT }
    its(:logger) { should eql PanamaxAgent::Configuration::DEFAULT_LOGGER }
  end
end
