require 'spec_helper'

describe PanamaxAgent::Client do

  describe '#initialize' do

    after do
      PanamaxAgent.reset
    end

    PanamaxAgent::Configuration::VALID_OPTIONS_KEYS.each do |option|
      it "inherits default #{option} value from Panamax" do
        client = PanamaxAgent::Client.new
        expect(client.send(option)).to eql(PanamaxAgent.send(option))
      end

      it "overrides default for #{option} when specified" do
        client = PanamaxAgent::Client.new(option => :foo)
        expect(client.send(option)).to eql(:foo)
      end
    end
  end
end
