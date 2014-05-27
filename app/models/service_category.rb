class ServiceCategory < ActiveRecord::Base
  belongs_to :service
  belongs_to :app_category

  delegate :name, to: :app_category
end
