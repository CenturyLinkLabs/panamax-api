require 'spec_helper'

describe PanamaxAgent::Response::FixBadJson do

  describe '#parse' do

    context 'when response body is empty' do
      let(:env) do
        {
          headers: { accept: 'application/json' },
          body: ''
        }
      end

      it 'raises no errors' do
        expect { subject.parse(env[:body]) }.to_not raise_error
      end
    end

    context 'when response body returns well-formatted json' do
      let(:env) do
        {
          headers: { accept: 'application/json' },
          body: '[ { "SOME_KEY_1" : "VALUE-1" }, { "SOME_KEY_1" : "VALUE-2" } ]'
        }
      end

      it 'raises no errors' do
        expect { subject.parse(env[:body]) }.to_not raise_error
      end

    end

    context 'when response body returns bad-formatted json' do
      let(:env) do
        {
          headers: { accept: 'application/json' },
          body: '{ "SOME_KEY_1" : "VALUE-1" } { "SOME_KEY_1" : "VALUE-2" }'
        }
      end

      it 'raises no errors' do
        expect { subject.parse(env[:body]) }.to_not raise_error
      end
    end
  end
end
