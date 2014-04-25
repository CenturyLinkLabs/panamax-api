class ImageCategory < ActiveRecord::Base
  belongs_to :image
  belongs_to :template_category

  validates :image_id, uniqueness: { scope: :template_category_id }
end
