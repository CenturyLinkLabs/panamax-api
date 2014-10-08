class RemoteImage < ApiModel

  attr_accessor :id
  attr_accessor :tags
  attr_accessor :description
  attr_accessor :is_official
  attr_accessor :is_trusted
  attr_accessor :star_count

  # At this time, find_by_name only populates the id and tags, getting
  # is_official, is_trusted and star_count would require another service call
  def self.find_by_name(name)
    tags = PanamaxAgent.registry_client.list_repository_tags(name)
    new(id: name, tags: tags.map { |tag| tag['name'] })
  end
end
