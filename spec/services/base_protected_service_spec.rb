require 'spec_helper'

describe BaseProtectedService do

  let(:endpoint_url) { 'http://endpoint.com' }
  let(:user) { 'foo_user' }
  let(:password) { 'bar_password' }
  let(:ca_cert) { 'cacertificate' }

  let(:response_body) { '{ "message": "authenticated" }' }

  describe '#with_ssl_connection' do

    context 'configuring ssl' do

      let(:fake_file) do
        double(:fake_file, path: '/tmp/fake', write: nil, close: nil, unlink: nil)
      end

      subject do
        Class.new(described_class) do
          def tester
            with_ssl_connection { |connection| connection }
          end
        end.new(endpoint_url: endpoint_url, user: user, password: password, ca_cert: ca_cert)
      end

      before do
        Tempfile.stub(:new).and_return(fake_file)
      end

      it 'configures SSL properly' do
        expect(fake_file).to receive(:write).with(ca_cert)
        subject.tester
      end

      it 'closes the certificate file' do
        expect(fake_file).to receive(:close)
        connection = subject.tester
      end

      it 'cleans-up the certificate file' do
        expect(fake_file).to receive(:unlink)
        connection = subject.tester
      end

      it 'verifies the server SSL certificate' do
        connection = subject.tester
        expect(connection.ssl[:verify_mode]).to eq 1
      end

    end

    context 'when sending a request' do

      subject do
        Class.new(described_class) do

          def tester
            with_ssl_connection do |connection|
              connection.get '/foo'
            end
          end
        end.new(endpoint_url: endpoint_url, user: user, password: password, ca_cert: ca_cert)
      end

      before do
        stub_request(:get, 'foo_user:bar_password@endpoint.com/foo')
          .to_return(body: response_body, status: 200)
      end

      it 'sends an authenticated request to the proper endpoint' do
        response = subject.tester
        expect(response.body).to eq(JSON.parse(response_body))
      end
    end

  end
end
