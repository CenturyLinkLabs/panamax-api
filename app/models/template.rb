class Template < ActiveRecord::Base
  include TemplateGithub

  has_and_belongs_to_many :images

  scope :recommended, -> { where(recommended: true) }
  scope :named_like, -> (name) { where('name LIKE ?', "%#{name}%") }

  def categories
    images.map(&:categories).flatten.uniq.compact
  end

  def as_json(options={})
    super(options).merge(image_count: images.count)
  end

end
