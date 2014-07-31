class TemplateRepo < ActiveRecord::Base

  after_create :reload_templates
  after_destroy :purge_templates

  validates :name, presence: true, uniqueness: true

  def files
    stream = open(archive_url)
    reader = Gem::Package::TarReader.new(Zlib::GzipReader.new(stream))

    reader.map do |item|
      next if item.directory?
      OpenStruct.new(name: item.full_name, content: item.read)
    end.compact
  end

  def load_templates
    self.files.each do |file|
      next unless file.name.end_with?('.pmx')
      TemplateBuilder.create(file.content).tap { |tpl| tpl.update_attributes(source: self.name) }
    end
  end

  def purge_templates
    Template.destroy_all(source: self.name)
  end

  def reload_templates
    transaction do
      purge_templates
      load_templates
    end
  end

  def self.load_templates_from_all_repos
    self.all.each(&:load_templates)
  end

  private

  def archive_url
    "https://github.com/#{name}/archive/master.tar.gz"
  end
end
