require 'spec_helper'

describe PanamaxAgent::Response::FixBadJson do

  describe '#parse_response?' do

    context 'when body is JSON array' do

      let(:env) { { body: '[]' } }

      it 'returns false' do
        expect(subject.parse_response?(env)).to eq false
      end
    end

    context 'when body is NOT JSON array' do

      let(:env) { { body: '{}' } }

      it 'returns true' do
        expect(subject.parse_response?(env)).to eq true
      end
    end
  end

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
