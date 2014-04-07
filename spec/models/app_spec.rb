require 'spec_helper'

describe App do
  it { should have_many(:services) }
end