require 'spec_helper'

describe App do
  it { should have_many(:services) }

  describe '.create_from_template' do
    it 'creates a new app using values from the template' do
      template = Template.where(name: 'wordpress').first
      expect(App).to receive(:create).with(name: template.name, from: "Template: #{template.name}").and_return(true)
      App.create_from_template(template)
    end

  end
end