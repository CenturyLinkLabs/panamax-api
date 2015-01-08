require 'spec_helper'

describe JobTemplateBuilder do

  let(:options) do
    HashWithIndifferentAccess.new(
      description: 'some template',
      keywords: 'foo,baz,bar',
      type: 'ClusterJobTemplate'
    )
  end

  describe '.create' do

    context 'when passed a JSON string' do
      it 'returns a template' do
        t = described_class.create("{'name':'my-new-template'}")
        expect(t).to be_a JobTemplate
        expect(t.name).to eq 'my-new-template'
      end
    end

  end

end
