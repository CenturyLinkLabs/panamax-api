class Registry < ActiveRecord::Base
  validates :name, presence: true
  validates :endpoint_url, presence: true
end
