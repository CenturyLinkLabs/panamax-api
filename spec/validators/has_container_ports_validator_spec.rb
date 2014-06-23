require 'spec_helper'

describe HasContainerPortsValidator do

  subject { described_class.new(attributes: [:ports_attr]) }

  let(:model) { double('model') }

  before do
    model.stub_chain('errors', '[]').and_return({})
  end

  it 'returns no errors for ports with container ports' do
    expect(model).to_not receive('errors')
    subject.validate_each(model, 'ports_attr', [{ 'host_port' => 80, 'container_port' => 8080 },
                                                { 'host_port' => 81, 'container_port' => 7070 }])
  end

  it 'should validate invalid address' do
    expect(model.errors[]).to receive('<<').with("container port can't be blank").once
    subject.validate_each(model, 'ports_attr', [{ 'host_port' => 80 }])
  end

end
