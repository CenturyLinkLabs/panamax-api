class TemplateRepo < ActiveRecord::Base

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

  def purge_templates
    Template.destroy_all(source: self.name)
  end

  private

  def archive_url
    "https://github.com/#{name}/archive/master.tar.gz"
  end
end
