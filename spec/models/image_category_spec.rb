require 'spec_helper'

describe ImageCategory do
  it { should belong_to :image }
  it { should belong_to :template_category }
  it { should validate_uniqueness_of(:image_id).scoped_to(:template_category_id) }
end
