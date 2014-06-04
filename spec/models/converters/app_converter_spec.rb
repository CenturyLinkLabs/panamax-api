require 'spec_helper'

describe Converters::AppConverter do

  subject { described_class.new(apps(:app1)) }

  it 'creates a Template from the given App' do
    expect(subject.to_template).to be_a Template
  end

  it "converts the App's Services to the Template's Images" do
    expect(subject.to_template.images.size).to eq apps(:app1).services.size
  end

end
