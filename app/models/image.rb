class Image < ActiveRecord::Base
  include Classifiable

  self.inheritance_column = :_type_disabled

  EMPTY_REPO = '<none>'

  attr_accessor :is_official
  attr_accessor :is_trusted
  attr_accessor :star_count

  serialize :categories, Array
  serialize :links, Array
  serialize :ports, Array
  serialize :expose, Array
  serialize :environment, Array
  serialize :volumes, Array

  belongs_to :template

  validates_presence_of :name
  validates_presence_of :source
  validates :ports, has_container_ports: true, has_unique_ports: true
  validates :links, has_link_alias: true, service_link_exists: true
  validates :volumes, has_container_paths: true

  def self.search_remote_index(query, limit=nil)
    images = Docker::Image.search(term: query)

    images = images.first(limit) if limit

    images.map do |image|
      new(
        source: image.id,
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
      repo, _tag = repotags.first.split(':')

      if repo != EMPTY_REPO
        new(source: repo)
      else
        nil
      end
    end

    # Remove nils and duplicates
    images.compact.uniq(&:source)
  end

  def self.local_with_repo_like(search_term, limit=nil)
    images = self.all_local.select { |image| image.source =~ /#{search_term}/ }.compact
    limit.nil? ? images : images.first(limit)
  end

  def self.find_local_for(name)
    Docker::Image.all.select { |i| i.info['RepoTags'].first.start_with? "#{name}:" }
  end

  def recommended
    self[:recommended] || false
  end

  def as_json(options={})
    super(options).merge(is_official: is_official, is_trusted: is_trusted, star_count: star_count)
  end

end
