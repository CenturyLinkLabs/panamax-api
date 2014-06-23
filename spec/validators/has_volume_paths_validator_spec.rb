require 'spec_helper'

describe HasVolumePathsValidator do

  subject { described_class.new(attributes: [:volumes_attr]) }

  let(:model) { double('model') }

  before do
    model.stub_chain('errors', '[]').and_return({})
  end

  it 'returns no errors for proper volume definition' do
    expect(model).to_not receive('errors')
    subject.validate_each(model, 'volumes_attr', [{ 'host_path' => '/foo', 'container_path' => '/bar' },
                                                  { 'host_path' => '/baz', 'container_path' => '/quux' }])
  end

  it 'should validate missing container path' do
    expect(model.errors[]).to receive('<<').with("container path and host path can't be blank").once
    subject.validate_each(model, 'volumes_attr', [{ 'host_path' => '/foo' }, { '/host_path' => 'bar' }])
  end

  it 'should validate missing host path' do
    expect(model.errors[]).to receive('<<').with("container path and host path can't be blank").once
    subject.validate_each(model, 'volumes_attr', [{ 'container_path' => '/foo' }, { 'container_path' => '/bar' }])
  end

end
