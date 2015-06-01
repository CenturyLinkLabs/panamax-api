require 'spec_helper'

describe Converters::AppConverter do

  subject { described_class.new(apps(:app1)) }

  context '#to_template' do
    fixtures :apps

    it 'creates a Template from the given App' do
      expect(subject.to_template).to be_a Template
    end

    it "converts the App's Services to the Template's Images" do
      expect(subject.to_template.images.size).to eq apps(:app1).services.size
    end
  end

  context '#to_compose_yaml' do
    fixtures :apps, :services

    it 'creates a yaml string from the given App' do
      expect(subject.to_compose_yaml).to be_a String
    end

    it 'creates a yaml representation with the same services as the App' do
      yaml = subject.to_compose_yaml
      rb = YAML.load(yaml)
      expect(rb.keys).to match_array apps(:app1).services.map(&:name)
    end
  end
end
