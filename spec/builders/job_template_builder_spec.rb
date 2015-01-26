require 'spec_helper'

describe JobTemplateBuilder do

  describe '.create' do

    context 'when passed a Hash' do
      let(:options) { { 'name' => 'my-new-template' } }

      it 'returns a template' do
        t = described_class.create(options)
        expect(t).to be_a JobTemplate
        expect(t.name).to eq 'my-new-template'
      end
    end

    context 'when passed Parameters with an override key' do
      let(:options) { HashWithIndifferentAccess.new('name' => 'my-new-template') }

      it 'returns a template' do
        t = described_class.create(options)
        expect(t).to be_a JobTemplate
        expect(t.name).to eq 'my-new-template'
      end
    end
  end

  describe '.create_steps' do
    let('steps') do
      [
        {
          'name' => 'foo',
          'source' => 'foo/bar'
        },
        {
          'name' => 'baz',
          'source' => 'baz/quux'
        }
      ]
    end

    it 'creates a hash of job steps' do
      t = described_class.send(:create_steps, steps)
      expect(t).to all(be_a(JobTemplateStep))
    end

    it 'adds a position to each step' do
      t = described_class.send(:create_steps, steps)
      expect(t.first[:position]).to eq 1
      expect(t[1][:position]).to eq 2
    end
  end
end
