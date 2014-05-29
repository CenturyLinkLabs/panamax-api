require 'spec_helper'

describe PanamaxAgent::Response::RaiseError do

  describe '#on_complete' do

    context 'when HTTP status is 200' do

      let(:env) { { status: 200 } }

      it 'raises no errors' do
        expect { subject.on_complete(env) }.to_not raise_error
      end
    end

    context 'when the HTTP status is a known error (404)' do

      let(:message) { 'not found' }
      let(:error_code) { 999 }
      let(:cause) { 'just because ' }

      let(:env) do
        {
          status: 404,
          body: "{ \"message\": \"#{message}\", \"errorCode\": #{error_code}, \"cause\": \"#{cause}\" }"
        }
      end

      it 'raises a NotFound execption' do
        expect { subject.on_complete(env) }.to raise_error(PanamaxAgent::NotFound)
      end

      it 'sets the message on the exception' do
        begin
          subject.on_complete(env)
        rescue PanamaxAgent::NotFound => ex
          expect(ex.message).to eq message
        end
      end

      it 'sets the error code on the exception' do
        begin
          subject.on_complete(env)
        rescue PanamaxAgent::NotFound => ex
          expect(ex.error_code).to eq error_code
        end
      end

      it 'sets the cause on the exception' do
        begin
          subject.on_complete(env)
        rescue PanamaxAgent::NotFound => ex
          expect(ex.cause).to eq cause
        end
      end
    end

    context 'when HTTP status is an unknown error' do

      let(:env) do
        {
          status: 499,
          body: "{ \"message\": \"err\" }"
        }
      end

      it 'raises an Error execption' do
        expect { subject.on_complete(env) }.to raise_error(PanamaxAgent::Error)
      end
    end

    context 'when error body is not JSON parseable' do

      let(:env) do
        {
          status: 499,
          body: 'FOO BAR'
        }
      end

      it 'sets the error message to be the response body' do
        begin
          subject.on_complete(env)
        rescue PanamaxAgent::Error => ex
          expect(ex.message).to eq env[:body]
        end
      end
    end
  end
end
