require 'spec_helper'
require 'panamax_agent/middleware/response/listify_json'

describe PanamaxAgent::Response::ListifyJson do

  describe '#on_complete' do

    let(:body) { '' }

    let(:env) do
      {
        body: body
      }
    end

    context 'when response body is valid json' do

      let(:body) do
        '[ { "foo": "bar" }, { "fizz": "bin" } ]'
      end

      it 'returns the body untouched' do
        subject.on_complete(env)
        expect(env[:body]).to eq body
      end
    end

    context 'when response body is not valid json' do

      let(:body) do
        "{ \"foo\": \"bar\" }\n{ \"fizz\": \"bin\" }\n"
      end

      it 'returns the listified version of the body' do
        subject.on_complete(env)
        expect(env[:body]).to eq(
          '[' + body.chomp.gsub("\n", ',') + ']'
        )
      end
    end

  end
end
