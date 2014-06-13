class ServiceCategory < ActiveRecord::Base
  belongs_to :service
  belongs_to :app_category

  validates :app_category_id, presence: true, on: :update
  validates :position,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    allow_nil: true

  delegate :name, to: :app_category
end
