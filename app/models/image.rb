class Image < ActiveRecord::Base

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
        is_trusted: image.info['is_trusted'])
    end
  end

  def self.all_local
    images = Docker::Image.all
    images.map do |image|
      new(repository: image.info['RepoTags'].first)
    end
  end
end
