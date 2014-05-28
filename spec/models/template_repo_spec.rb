require 'spec_helper'

describe TemplateRepo do
  it { should respond_to(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
end
