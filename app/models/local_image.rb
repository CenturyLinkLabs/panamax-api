class LocalImage

  UNTAGGED = '<none>'

  attr_accessor :id, :tags

  # When using .all the ID is the same as the Docker image ID
  def self.all
    Docker::Image.all.map do |image|
      new(id: image.id,
        tags: image.info['RepoTags'] || [UNTAGGED])
    end
  end

  # When using .all_by_repo the ID is the repository name
  def self.all_by_repo
    all.each_with_object({}) do |image, memo|
      image.tags.each do |tag|
        repo, tag = tag.split(':')
        memo[repo] ||= new(id: repo)
        memo[repo].tags << tag
      end
    end.values.reject(&:untagged?)
  end

  def self.find_by_name(name)
    all_by_repo.find { |image| image.id == name }
  end

  def self.search(search_term, limit=nil)
    images = all_by_repo.select { |image| image.id =~ /#{search_term}/ }
    limit.nil? ? images : images.first(limit)
  end

  def initialize(options={})
    self.id = options[:id]
    self.tags = Array(options[:tags])
  end

  def untagged?
    id ==  UNTAGGED
  end
end
