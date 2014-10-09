require 'spec_helper'

describe Image do

  it_behaves_like 'a classifiable model'

  it { should respond_to(:deployment) }
  it { should belong_to(:template) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:source) }
end
