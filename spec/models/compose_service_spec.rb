require 'spec_helper'

describe ComposeService do
  it_behaves_like 'an api model'

  describe 'attributes' do
    it { should respond_to :name }
    it { should respond_to :image }
    it { should respond_to :ports }
    it { should respond_to :links }
    it { should respond_to :expose }
    it { should respond_to :environment }
    it { should respond_to :volumes }
    it { should respond_to :volumes_from }
    it { should respond_to :command }
  end
end
