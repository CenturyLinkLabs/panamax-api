require 'spec_helper'

describe HasUniquePortsValidator do

  subject { described_class.new(attributes: [:ports_attr]) }

  let(:model) { double('model') }

  before do
    model.stub_chain('errors', '[]').and_return({})
  end

  it 'returns no errors for ports with when they are unique' do
    expect(model).to_not receive('errors')
    subject.validate_each(model, 'ports_attr', [{ 'host_port' => 80, 'container_port' => 8080 },
                                                { 'host_port' => 81, 'container_port' => 7070 }])
  end

  it 'returns errors when there are duplicated ports' do
    expect(model.errors[]).to receive('<<').with('host ports must be unique').once
    subject.validate_each(model, 'ports_attr', [{ 'host_port' => 80 }, { 'host_port' => 80 }])
  end

end
