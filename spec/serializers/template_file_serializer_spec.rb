require 'spec_helper'

describe TemplateFileSerializer do
  let(:template_model) { Template.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(template_model).as_json
    expected_keys = [
      :name,
      :description,
      :keywords,
      :type,
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
        type: 'wordpress',
        documentation: "This\n\is\nthe\ndocumentation",
        images: [
          Image.new(
            name: 'abc',
            source: 'def',
            type: 'ghi',
            categories: ['jkl'],
            expose: [8000],
            environment: [{ 'variable' => 'mno', 'value' => 'pqr' }],
            volumes: [{ 'host_path' => '/tmp/foo', 'container_path' => '/tmp/bar' }],
            volumes_from: [{ 'container_name' => 'foodata' }, { 'container_name' => 'bardata' }]
          )
        ]
      )
    end

    it 'yamlizes the model appropriately' do
      response = described_class.new(template_model).to_yaml

      expect(response).to eq <<-EXPECTED
---
name: foo
description: bar
keywords: fizz, bin
type: wordpress
documentation: |-
  This
  is
  the
  documentation
images:
- name: abc
  source: def
  category: jkl
  type: ghi
  expose:
  - 8000
  environment:
  - variable: mno
    value: pqr
  volumes:
  - host_path: "/tmp/foo"
    container_path: "/tmp/bar"
  volumes_from:
  - container_name: foodata
  - container_name: bardata
      EXPECTED
    end

  end
end
