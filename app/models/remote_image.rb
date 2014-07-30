class RemoteImage

  attr_accessor :id
  attr_accessor :tags
  attr_accessor :description
  attr_accessor :is_official
  attr_accessor :is_trusted
  attr_accessor :star_count

  def self.search(search_term, limit=nil)
    images = Docker::Image.search(term: search_term)

    images = images.first(limit) if limit

    images.map do |image|
      new(
        id: image.id,
        description: image.info['description'],
        is_official: image.info['is_official'],
        is_trusted: image.info['is_trusted'],
        star_count: image.info['star_count'])
    end
  end

  # At this time, find_by_name only populates the id and tags, getting
  # is_official, is_trusted and star_count would require another service call
  def self.find_by_name(name)
    tags = PanamaxAgent.registry_client.list_repository_tags(name)
    new(id: name, tags: tags.map { |tag| tag['name'] })
  end

  def initialize(options={})
    self.id = options[:id]
    self.tags = Array(options[:tags])
    self.description = options[:description]
    self.is_official = options[:is_official]
    self.is_trusted = options[:is_trusted]
    self.star_count = options[:star_count]
  end
end
