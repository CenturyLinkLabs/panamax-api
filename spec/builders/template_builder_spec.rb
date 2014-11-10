require 'spec_helper'

describe TemplateBuilder do

  let(:options) do
    HashWithIndifferentAccess.new(
      description: 'some template',
      keywords: 'foo,baz,bar',
      type: 'wordpress'
    )
  end

  describe '.create' do

    context 'when an app_id is passed' do
      fixtures :apps
      before { options[:app_id] = apps(:app1).id }

      it 'returns a template created from the application' do
        t = described_class.create(options)
        expect(t).to be_a Template
        expect(t.name).to eq apps(:app1).name
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

    context 'when passed a fig_yml param' do
      before { options[:fig_yml] = '---' }

      it 'returns a template created from the fig template' do
        t = described_class.create(options)
        expect(t).to be_a Template
      end
    end

    context 'when passed a JSON string' do
      it 'returns a template' do
        t = described_class.create("{'name':'my-new-template'}")
        expect(t).to be_a Template
        expect(t.name).to eq 'my-new-template'
      end
    end

    context 'when invalid options are passed' do
      subject { described_class.create(nil) }
      it 'returns a template with errors' do
        expect(subject.valid?).to be_false
      end

      it 'returns an unpersisted template' do
        expect(subject.persisted?).to be_false
      end
    end

    context 'when persisted flag is passed' do
      let(:strategy) { double(:strategy) }
      before do
        TemplateBuilder::FromApp.stub(:new).and_return(strategy)
      end
      it 'passes through to the strategy' do
        expect(strategy).to receive(:create_template).with(false)
        described_class.create({ app_id: 1 }, false)
      end
    end

  end

end
