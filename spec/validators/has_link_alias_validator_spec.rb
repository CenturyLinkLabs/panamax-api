require 'spec_helper'

describe HasLinkAliasValidator do

  subject { described_class.new(attributes: [:links_attr]) }

  let(:model) { double('model') }

  before do
    model.stub_chain('errors', '[]').and_return({})
  end

  it 'returns no errors for links with aliases' do
    expect(model).to_not receive('errors')
    subject.validate_each(model, 'links_attr', [{ 'service' => 'foo', 'alias' => 'bar' },
                                                { 'service' => 'baz', 'alias' => 'quux' }])
  end

  it 'should validate missing alias' do
    expect(model.errors[]).to receive('<<').with("link alias can't be blank").once
    subject.validate_each(model, 'links_attr', [{ 'service' => 'foo' }, { 'service' => 'bar' }])
  end

end
