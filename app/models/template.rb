class Template < ActiveRecord::Base
  has_and_belongs_to_many :images

  scope :recommended, -> { where(recommended: true) }
  scope :named_like, -> (name){ where("name LIKE ?", "%#{name}%") }

end
