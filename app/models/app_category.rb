class AppCategory < ActiveRecord::Base
  belongs_to :app

  validates :name, uniqueness: { scope: :app_id }
  validates :app_id, presence: true, on: :update

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Category')
  end
end
