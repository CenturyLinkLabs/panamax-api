class Template < ActiveRecord::Base
  include TemplateGithub

  has_and_belongs_to_many :images

  serialize :authors, Array

  scope :recommended, -> { where(recommended: true) }
  scope :named_like, -> (name) { where('name LIKE ?', "%#{name}%") }

  validates_presence_of :name

  def categories
    images.map(&:categories).flatten.uniq.compact
  end

  def as_json(options={})
    super(options).merge(image_count: images.count)
  end

end
