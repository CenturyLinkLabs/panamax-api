class AppCategory < ActiveRecord::Base
  belongs_to :app

  validates :name, uniqueness: { scope: :app_id }
end
