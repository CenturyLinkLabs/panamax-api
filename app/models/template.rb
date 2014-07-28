class Template < ActiveRecord::Base
  include Classifiable
  include TemplateGithub

  self.inheritance_column = :_type_disabled

  has_many :images

  serialize :authors, Array

  validates_presence_of :name

  def categories
    images.map(&:categories).flatten.uniq.compact
  end

  def self.search(term, limit=nil)
    term = term.gsub(',', ' ')
    results = term.split.each_with_object([]) do |t, a|
      a << self.where('name LIKE ? OR keywords LIKE ?', "%#{t}%", "%#{t}%")
    end.flatten.uniq.compact

    limit.nil? ? results : results.first(limit)
  end

end
