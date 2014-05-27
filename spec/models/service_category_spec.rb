require 'spec_helper'

describe ServiceCategory do
  it { should delegate_method(:name).to(:app_category) }
end
