require 'spec_helper'

describe ServiceCategory do

  it { should validate_presence_of(:app_category_id).on(:update) }

  it do
    should validate_numericality_of(:position)
      .only_integer
      .is_greater_than_or_equal_to(0)
  end

  it { should delegate_method(:name).to(:app_category) }
end
