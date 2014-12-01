require 'spec_helper'

describe ApplicationController do

  describe 'handling StandardError exceptions' do

    controller do
      def index
        raise StandardError, 'oops'
      end
    end

    it 'logs some info at the error level' do
      expect(controller.logger).to receive(:error).once
      get :index
    end

    it 'returns a 500 status code' do
      get :index
      expect(response.status).to eq 500
    end

    it 'renders the error message in the response body' do
      get :index
      expect(response.body).to eq({ message: 'oops' }.to_json)
    end
  end

  describe 'handling Docker::Error::ServerError exceptions' do

    controller do
      def index
        raise Docker::Error::ServerError, 'oops'
      end
    end

    it 'renders the github connection error in the response body' do
      get :index
      expect(response.status).to eq 500
      expect(response.body).to eq(
        { message: I18n.t(:docker_connection_error) }.to_json)
    end
  end

  describe '#handle_exception' do

    context 'when a message is provided' do

      controller do
        def index
          raise StandardError, 'oops'
        rescue => ex
          handle_exception(ex, 'uh-oh')
        end
      end

      it 'renders the provided message in the response body' do
        get :index
        expect(response.body).to eq({ message: 'uh-oh' }.to_json)
      end
    end

    context 'when a translated message key is provided' do

      controller do
        def index
          raise StandardError, 'oops'
        rescue => ex
          handle_exception(ex, :hello)
        end
      end

      it 'renders the translated message in the response body' do
        get :index
        expect(response.body).to eq({ message: I18n.t(:hello) }.to_json)
      end
    end

    context 'when a block is provided that does not render' do

      controller do
        def index
          raise StandardError, 'oops'
        rescue => ex
          handle_exception(ex) { logger.warn('debug information') }
        end
      end

      it 'invokes the block' do
        expect(controller.logger).to receive(:warn).once
        get :index
      end

      it 'returns a 500 status code' do
        get :index
        expect(response.status).to eq 500
      end

      it 'renders the error message in the response body' do
        get :index
        expect(response.body).to eq({ message: 'oops' }.to_json)
      end
    end

    context 'when a block is provided that renders a response' do

      controller do
        def index
          raise StandardError, 'oops'
        rescue => ex
          handle_exception(ex) { render text: 'whoops', status: 777 }
        end
      end

      it 'invokes the block in lieu of the defaut render logic' do
        get :index
        expect(response.status).to eq 777
        expect(response.body).to eq 'whoops'
      end
    end
  end

  describe '#log_kiss_event' do

    controller do
      def index
        log_kiss_event('foo', 'bar')
      end
    end

    context 'when user email is set' do

      let(:email) { 'foo@bar.com' }

      before do
        allow(User).to receive(:instance).and_return(double(:user, primary_email: email))
      end

      it 'logs the event with the user email address' do
        expect(KMTS).to receive(:record).with(email, 'foo', 'bar')
        get :index
      end
    end

    context 'when user email is not set' do

      let(:panamax_id) { 'abc123def456' }

      before do
        ENV['PANAMAX_ID'] = panamax_id
        allow(User).to receive(:instance).and_return(double(:user, primary_email: nil))
      end

      it 'logs the event with the panamax ID' do
        expect(KMTS).to receive(:record).with(panamax_id, 'foo', 'bar')
        get :index
      end
    end

  end
end
