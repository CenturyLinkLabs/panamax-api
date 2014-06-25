require 'spec_helper'

describe TemplateFileSerializer do
  let(:template_model) { Template.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(template_model).as_json
    expected_keys = [
      :name,
      :description,
      :keywords,
      :recommended,
      :icon,
      :documentation,
      :images
    ]
    expect(serialized.keys).to match_array expected_keys
  end

  describe '#to_yaml' do

    let(:template_model) do
      Template.new(
        name: 'foo',
        description: 'bar',
        keywords: 'fizz, bin',
        recommended: true,
        icon: 'icon.png',
        documentation: "This\n\is\nthe\ndocumentation"
      )
    end

    it 'yamlizes the model appropriately' do
      response = described_class.new(template_model).to_yaml

      expect(response).to eq <<-EXPECTED
---
name: foo
description: bar
keywords: fizz, bin
recommended: true
icon: icon.png
documentation: |-
  This
  is
  the
  documentation
images: []
      EXPECTED
    end

  end
end
