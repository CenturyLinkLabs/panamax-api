module TemplateGithub
  extend ActiveSupport::Concern

  def save_to_repo(params)
    repo            = params[:repo]
    file_name       = params[:file_name] || "#{name}"
    file_path       = params[:file_path] || ''
    commit_message  = params[:commit_message] || "Saved a Panamax template #{file_name}.pmx"
    branch          = params[:branch]
    file_obj        = params[:file]
    opts = {}
    opts[:branch]   = branch if branch
    opts[:file]     = file_obj if file_obj

    file_full_path  = "#{file_path}#{file_name}.pmx"
    # use template contents saved in the database
    contents = TemplateFileSerializer.new(self).to_yaml

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

  def github_client
    @github_client ||= Octokit::Client.new(access_token: User.instance.github_access_token)
  end
end
