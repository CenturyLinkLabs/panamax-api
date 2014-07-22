require 'spec_helper'

describe TemplateBuilder::FromJson do

  let(:template_json) { fixture_data 'wordpress.pmx'  }

  subject { described_class.new template_json }

  context '.create_template' do
    it 'creates a template from the json data' do
      expect(subject.create_template).to be_a(Template)
    end

    it 'persists the template if the json data is valid' do
      expect(subject.create_template).to be_persisted
    end

    it 'returns the template with errors if the json data is not valid' do
      invalid_template_json = '{}'
      strategy = described_class.new invalid_template_json
      expect(strategy.create_template).to_not be_valid
      expect(strategy.create_template).to_not be_persisted
      expect(strategy.create_template.errors).to_not be_empty
    end

    context 'when persisted flag is false' do
      it 'returns an unpersisted template' do
        t = subject.create_template(false)
        expect(t.persisted?).to be_false
      end
    end
  end

end
