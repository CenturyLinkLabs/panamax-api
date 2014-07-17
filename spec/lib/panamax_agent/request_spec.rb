require 'spec_helper'

describe PanamaxAgent::Request do

  subject { PanamaxAgent::Client.new }

  let(:path) { '/path' }

  let(:request) do
    double(:request,
      options: {},
      headers: {},
      params: {},
      'headers=' => nil,
      'path=' => nil)
  end

  let(:response) do
    double(:response, body: 'foo')
  end

  let(:connection) { double(:connection) }

  before do
    connection.stub(:send).and_yield(request).and_return(response)
    subject.stub(:connection).and_return(connection)
  end

  [:get, :delete, :head, :put, :post].each do |method|

    context "##{method}" do

      it 'sets the path' do
        expect(request).to receive(:path=).with(path)
        subject.send(method, path)
      end

      it 'sets the headers' do
        headers = { foo: :bar }
        expect(request).to receive(:headers=).with(hash_including(headers))
        subject.send(method, path, {}, headers)
      end

      it 'returns the response body' do
        expect(subject.send(method, path)).to eql(response.body)
      end

      context 'when a Faraday::Error::ConnectionFailed error is raised' do

        before do
          connection.stub(:send).and_raise(Faraday::Error::ConnectionFailed, 'oops')
        end

        it 'raises a PanamaxAgent::ConnectionError' do
          expect { subject.send(method, path) }.to raise_error(PanamaxAgent::ConnectionError, 'oops')
        end
      end
    end
  end

  [:get, :delete, :head].each do |method|

    context "##{method}" do

      context 'when options provided' do

        it 'sets options on the request' do
          options = { a: :b }
          expect(request).to receive(:params=).with(options)
          subject.send(method, path, options)
        end
      end

      context 'when no options provided' do

        it 'does not set options on the request' do
          expect(request).to_not receive(:params=)
          subject.send(method, path)
        end
      end
    end
  end

  [:put, :post].each do |method|

    context "##{method}" do

      context 'when options provided' do

        it 'sets options on the request' do
          options = { a: :b }
          expect(request).to receive(:body=).with(options)
          subject.send(method, path, options)
        end
      end

      context 'when no options provided' do

        it 'does not set options on the request' do
          expect(request).to_not receive(:body=)
          subject.send(method, path)
        end
      end

      context 'when querystring AND body provided' do
        let(:options) { { querystring: { a: :b }, body: { c: :d } } }

        before do
          request.stub(:params=)
          request.stub(:body=)
        end

        it 'sets the querystring as request params' do
          expect(request).to receive(:params=).with(options[:querystring])
          subject.send(method, path, options)
        end

        it 'sets the body as request body' do
          expect(request).to receive(:body=).with(options[:body])
          subject.send(method, path, options)
        end
      end

    end
  end

end
