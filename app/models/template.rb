class Template < ActiveRecord::Base
  has_and_belongs_to_many :images
  has_many :categories, class_name: 'TemplateCategory'

  scope :recommended, -> { where(recommended: true) }
  scope :named_like, -> (name){ where("name LIKE ?", "%#{name}%") }

  def as_json(options={})
    super(options).merge(image_count: images.count)
  end
end
