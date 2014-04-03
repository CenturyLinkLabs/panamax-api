require 'spec_helper'

describe PanamaxAgent::Configuration do

  subject { Class.new { extend PanamaxAgent::Configuration } }

  describe "exposed attribes" do
    PanamaxAgent::Configuration::VALID_OPTIONS_KEYS.each do |key|
      it { should respond_to key.to_sym }
    end
  end

  describe "default values" do
    its(:adapter) { should eql PanamaxAgent::Configuration::DEFAULT_ADAPTER }
    its(:registry_api_url) { should eql PanamaxAgent::Configuration::DEFAULT_REGISTRY_API_URL }
    its(:registry_api_version) { should eql PanamaxAgent::Configuration::DEFAULT_REGISTRY_API_VERSION }
    its(:open_timeout) { should eql  PanamaxAgent::Configuration::DEFAULT_OPEN_TIMEOUT }
    its(:read_timeout) { should eql PanamaxAgent::Configuration::DEFAULT_READ_TIMEOUT }
    its(:logger) { should eql PanamaxAgent::Configuration::DEFAULT_LOGGER }
  end
end
