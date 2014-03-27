require 'spec_helper'

describe Template do
  it { should have_and_belong_to_many(:images) }
end
