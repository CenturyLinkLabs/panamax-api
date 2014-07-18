require 'spec_helper'

describe ApplicationController do

  describe 'handling exceptions' do

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

    context 'when error handler is invoked directly' do

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
  end
end
