require 'spec_helper'

describe TemplateBuilder do

  describe '.create' do
    let(:options) do
      HashWithIndifferentAccess.new(
        description: 'some template',
        keywords: 'foo,baz,bar',
        recommended: true,
        icon: 'foo.png',
        documentation: '---\n\nBlah\n\n'
      )
    end

    context 'when passed an app_id' do
      before { options[:app_id] = apps(:app1).id }

      it 'returns a template created from the application' do
        t = described_class.create(options)
        expect(t).to be_a Template
        expect(t.name).to eq apps(:app1).name
      end
    end

    context 'when passed a fig_yml param' do
      before { options[:fig_yml] = '---' }

      it 'returns a template created from the fig template' do
        t = described_class.create(options)
        expect(t).to be_a Template
      end
    end

    context 'when no app_id is provided' do
      before { options[:name] = 'my-new-template' }

      it 'returns a template' do
        t = described_class.create(options)
        expect(t).to be_a Template
        expect(t.name).to eq 'my-new-template'
      end
    end

    context 'when options are provided as a JSON string' do
      it 'returns a template' do
        t = described_class.create("{'name':'my-new-template'}")
        expect(t).to be_a Template
        expect(t.name).to eq 'my-new-template'
      end
    end

    context 'when passed invalid options' do
      subject { described_class.create(nil) }
      it 'returns a template with errors' do
        expect(subject.valid?).to be_false
      end

      it 'returns an unpersisted template' do
        expect(subject.persisted?).to be_false
      end
    end

  end

end
