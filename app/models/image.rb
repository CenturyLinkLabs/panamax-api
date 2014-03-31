class Image < ActiveRecord::Base

  EMPTY_REPO = '<none>'

  attr_accessor :is_official
  attr_accessor :is_trusted
  attr_accessor :star_count

  has_and_belongs_to_many :templates

  def self.search_remote_index(query={})
    images = Docker::Image.search(query)
    images.map do |image|
      new(
        repository: image.id,
        description: image.info['description'],
        is_official: image.info['is_official'],
        is_trusted: image.info['is_trusted'],
        star_count: image.info['star_count'])
    end
  end

  def self.all_local
    local_images = Docker::Image.all

    images = local_images.map do |image|
      repotags = image.info['RepoTags'] || [EMPTY_REPO]

      # Arbitrarily pick the first tag since the part we care about should
      # be the same for all of them anyway.
      repo, tag = repotags.first.split(':')

      if repo != EMPTY_REPO
        new(repository: repo)
      else
        nil
      end
    end

    # Remove nils and duplicates
    images.compact.uniq { |image| image.repository }
  end
end
