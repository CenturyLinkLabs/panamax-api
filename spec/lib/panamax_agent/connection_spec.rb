require 'spec_helper'

describe PanamaxAgent::Connection do

  describe "registered middleware" do
    subject { PanamaxAgent::Client.new.connection }

    handlers = [
      FaradayMiddleware::EncodeJson,
      FaradayMiddleware::Mashify,
      FaradayMiddleware::ParseJson,
      Faraday::Adapter::NetHttp
    ]

    handlers.each do |handler|
      it { expect(subject.builder.handlers).to include handler }
    end

    it "includes exactly #{handlers.count} handlers" do 
      expect(subject.builder.handlers.count).to eql handlers.count
    end
  end
end
