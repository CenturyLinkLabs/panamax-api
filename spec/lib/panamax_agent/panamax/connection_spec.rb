require 'spec_helper'

describe PanamaxAgent::Panamax::Connection do

  describe 'registered middleware' do

    subject { PanamaxAgent::Panamax::Client.new.connection }

    handlers = [
      Faraday::Request::UrlEncoded,
      FaradayMiddleware::ParseJson,
      PanamaxAgent::Response::RaiseError,
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
