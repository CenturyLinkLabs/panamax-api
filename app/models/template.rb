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

  def self.all_keywords
    self.select(:keywords).each_with_object(Hash.new(0)) do |t, h|
      t.keywords.split(',').each do |kw|
        h[kw.strip.downcase] += 1
      end
    end.each_with_object([]) do |(k, v), keywords|
      keywords << { keyword: k, count: v }
    end
  end

  def self.search(term, limit=nil)
    term = term.gsub(',', ' ')
    results = term.split.each_with_object([]) do |t, a|
      a << self.where('name LIKE ? OR keywords LIKE ?', "%#{t}%", "%#{t}%")
    end.flatten.uniq.compact

    limit.nil? ? results : results.first(limit)
  end

end
