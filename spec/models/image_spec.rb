require 'spec_helper'

describe Image do
  it { should have_and_belong_to_many(:templates) }
end
