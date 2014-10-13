class Registry < ActiveRecord::Base
  validates :name, presence: true
  validates :endpoint_url, presence: true

  def self.docker_hub
    self.find(0)
  end

  def self.search(term, limit=nil)
    results = self.where(enabled: true).each_with_object([]) do |registry, a|
      a << registry.search(term)
    end.flatten
    limit ? results.first(limit) : results
  end

  def search(term)
    response = registry_client.search(term)
    response["results"].map do |r|
      RemoteImage.new(
        id: r['name'],
        description: r['description'],
        is_official: r['is_official'],
        is_trusted: r['is_trusted'],
        star_count: r['star_count'],
        registry_id: id
      )
    end
  end

  # At this time, find_by_name only populates the id and tags, getting
  # is_official, is_trusted and star_count would require another service call
  def find_image_by_name(name)
    tags = registry_client.list_repository_tags(name)
    RemoteImage.new(id: name, tags: coerce_tags(tags))
  end

  private

  def coerce_tags(tags)
    tags.map { |k,v| k.try(:[], "name") || k }
  end

  def registry_client
    @registry_client ||= PanamaxAgent::Registry::Client.new(
      registry_api_url: endpoint_url
    )
  end
end
