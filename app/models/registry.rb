class Registry < ActiveRecord::Base
  validates :name, presence: true
  validates :endpoint_url, presence: true

  def self.search(term, limit=nil)
    results = self.all.each_with_object([]) do |registry, a|
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
        star_count: r['star_count']
      )
    end
  end

  private

  def registry_client
    @registry_client ||= PanamaxAgent::Registry::Client.new(
      registry_api_url: endpoint_url
    )
  end
end
