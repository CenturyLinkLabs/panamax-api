require 'spec_helper'

describe PanamaxAgent::Mailchimp::Connection do

  describe 'registered middleware' do

    subject { PanamaxAgent::Mailchimp::Client.new.connection }

    handlers = [
      Faraday::Request::UrlEncoded,
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
