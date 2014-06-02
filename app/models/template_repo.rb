class TemplateRepo < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  def files
    GithubRepoFileEnumerator.new(name)
  end
end
