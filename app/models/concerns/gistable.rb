module Gistable
  extend ActiveSupport::Concern

  def from_gist(url)
    gist = Octokit::Gist.from_url(url)
    # remove 'gists/' path from gist id
    response = github_client.gist(gist.to_s.gsub("gists/", ""))
    response[:files].to_hash.map { |k, data| data }
  end

  def to_gist(params)
    options = {}
    options[:description] = params[:description]
    options[:public]      = params[:public] || false
    if params[:file_name] && params[:file_content]
      options[:files] = {
        params[:file_name] => {
          :content => params[:file_content]
        }
      }
    end

    # create a new gist
    response = github_client.create_gist(options) if options
    response[:url]
  end

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: User.instance.github_access_token)
  end
end
