require 'spec_helper'

describe RemoteImage do

  it_behaves_like 'an api model'

  describe 'attributes' do
    it { should respond_to :id }
    it { should respond_to :registry_id }
    it { should respond_to :tags }
    it { should respond_to :description }
    it { should respond_to :is_official }
    it { should respond_to :is_trusted }
    it { should respond_to :star_count }
  end

end
