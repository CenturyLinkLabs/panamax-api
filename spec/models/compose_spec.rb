require 'spec_helper'

describe Compose do
  it_behaves_like 'an api model'

  describe 'attributes' do
    it { should respond_to :name }
    it { should respond_to :services }
  end
end
