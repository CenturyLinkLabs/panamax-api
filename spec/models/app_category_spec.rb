require 'spec_helper'

describe AppCategory do
  it { should belong_to :app }
  it { should validate_uniqueness_of(:name).scoped_to(:app_id) }
end
