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

  context '#to_compose' do
    fixtures :apps, :services

    it 'creates a Compose model from the given App' do
      expect(subject.to_compose).to be_a Compose
    end

    it "converts the App's Services to the Compose model's ComposeServices" do
      expect(subject.to_compose.services.size).to eq apps(:app1).services.size
    end
  end
end
