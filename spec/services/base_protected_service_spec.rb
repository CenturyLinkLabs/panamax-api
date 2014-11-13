require 'spec_helper'

describe BaseProtectedService do

  let(:endpoint_url) { 'http://endpoint.com' }
  let(:user) { 'foo_user' }
  let(:password) { 'bar_password' }
  let(:ca_cert) { 'cacertificate' }

  subject do
    Class.new(described_class) do
      def connection_tester
        with_ssl_connection do |connection|
          yield connection if block_given?
          connection
        end
      end

      def request_tester
        with_ssl_connection do |connection|
          connection.get '/foo'
        end
      end
    end.new(endpoint_url: endpoint_url, user: user, password: password, ca_cert: ca_cert)
  end

  describe '#with_ssl_connection' do

    context 'configuring ssl' do

      it 'sets-up the CA certificate with the correct contents' do
        subject.connection_tester do |connection|
          expect(File.read(connection.ssl[:ca_file])).to eq ca_cert
        end
      end

      it 'cleans-up the certificate file' do
        connection = subject.connection_tester
        expect(File.exist?(connection.ssl[:ca_file])).to be_false
      end

      it 'verifies the server SSL certificate' do
        connection = subject.connection_tester
        expect(connection.ssl[:verify]).to be_true
      end
    end

    context 'when sending a request' do

      let(:response_body) { '{ "message": "authenticated" }' }

      before do
        endpoint_host = URI.parse(endpoint_url).host
        stub_request(:get, "#{user}:#{password}@#{endpoint_host}/foo")
          .to_return(body: response_body, status: 200)
      end

      it 'sends an authenticated request to the proper endpoint' do
        response = subject.request_tester
        expect(response.body).to eq(JSON.parse(response_body))
      end
    end

  end
end
