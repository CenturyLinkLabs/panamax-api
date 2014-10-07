require 'spec_helper'

describe Registry do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:endpoint_url) }
end
