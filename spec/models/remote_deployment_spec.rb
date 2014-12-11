require 'spec_helper'

describe RemoteDeployment do

  it_behaves_like 'an api model'

  describe 'attributes' do
    it { should respond_to :id }
    it { should respond_to :id= }
    it { should respond_to :name }
    it { should respond_to :name= }
    it { should respond_to :template }
    it { should respond_to :template= }
    it { should respond_to :service_ids }
    it { should respond_to :service_ids= }
    it { should respond_to :status }
    it { should respond_to :status= }
    it { should respond_to :redeployable }
    it { should respond_to :redeployable= }
  end

end
