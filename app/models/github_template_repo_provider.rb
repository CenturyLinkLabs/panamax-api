class GithubTemplateRepoProvider < TemplateRepoProvider

  DEFAULT_NAME = 'GitHub'
  EMAIL_SCOPES = %w(user user:email)

  validate :access_token_scope, on: :update

  after_initialize :set_name

  def set_name
    self.name ||= DEFAULT_NAME
  end

  def repos
    retrieve_from_github(:repos, []) do |repos|
      repos.map(&:full_name)
    end
  end

  def username
    retrieve_from_github(:user) do |user|
      user.login
    end
  end

  def email
    retrieve_from_github(:emails) do |emails|
      emails.find(&:primary).email
    end
  end

  def files_for(template_repo)
    stream = open("https://github.com/#{template_repo.name}/archive/master.tar.gz")
    reader = Gem::Package::TarReader.new(Zlib::GzipReader.new(stream))

    reader.map do |item|
      next if item.directory?
      OpenStruct.new(name: item.full_name, content: item.read)
    end.compact
  end

  def save_template(template, options={})
    repo            = options[:repo]
    file_name       = options[:file_name] || "#{template.name}"
    file_path       = options[:file_path] || ''
    commit_message  = options[:commit_message] || "Saved a Panamax template #{file_name}.pmx"
    branch          = options[:branch]
    file_obj        = options[:file]
    opts = {}
    opts[:branch]   = branch if branch
    opts[:file]     = file_obj if file_obj

    file_full_path  = "#{file_path}#{file_name}.pmx"
    contents = TemplateFileSerializer.new(template).to_yaml

    begin
      github_client.create_contents(repo, file_full_path, commit_message, contents, opts)
    rescue Octokit::UnprocessableEntity
      resp = github_client.contents(repo, path: file_full_path)
      github_client.update_contents(repo, file_full_path, commit_message, resp.sha, contents, opts)
    rescue Octokit::NotFound
      raise "Saving the template file failed due to insufficient privileges. Please select the access scope for the token to be at least 'repo' and 'user:email'."
    rescue Octokit::Unauthorized
      raise "Saving the template file failed due to missing, malformed or expired token."
    end

  end

  private

  def retrieve_from_github(resource, default=nil)
    @github_results ||= {}
    if @github_results.keys.include?(resource)
      result = @github_results[resource]
    else
      result = github_client.send(resource)
      @github_results[resource] = result
    end

    block_given? ? yield(result) : result
  rescue Octokit::NotFound, Octokit::Unauthorized
      default
  end

  def access_token_scope
    unless access_token_scoped_for_email?
      errors.add(:credentials_api_key, 'token too restrictive')
    end
  rescue Octokit::Unauthorized
    errors.add(:credentials_api_key, 'invalid token')
  end

  def access_token_scoped_for_email?
    (github_client.scopes & EMAIL_SCOPES).any?
  end

  def github_client
    Octokit::Client.new(access_token: credentials.api_key)
  end
end
