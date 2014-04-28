class AppCategory < ActiveRecord::Base
  belongs_to :app

  validates :name, uniqueness: { scope: :app_id }
  validates :app_id, presence: true
end
