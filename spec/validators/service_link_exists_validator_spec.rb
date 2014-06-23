require 'spec_helper'

describe ServiceLinkExistsValidator do

  subject { described_class.new(attributes: [:links_attr]) }

  let(:image_one) { double('image_one', name: 'foo') }
  let(:image_two) { double('image_two', name: 'bar') }
  let(:template) { double('template', images: [image_one, image_two]) }
  let(:model) { double('model', template: template) }

  before do
    model.stub_chain('errors', '[]').and_return({})
  end

  it 'returns no errors for links with existing services' do
    expect(model).to_not receive('errors')
    subject.validate_each(model, 'links_attr', [{ 'service' => 'foo', 'alias' => 'baz' },
                                                { 'service' => 'bar', 'alias' => 'quux' }])
  end

  it 'should validate missing services' do
    expect(model.errors[]).to receive('<<').with('linked service must exist').once
    subject.validate_each(model, 'links_attr', [{ 'service' => 'baz' }, { 'service' => 'quux' }])
  end
end
