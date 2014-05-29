module PanamaxAgent
  module Github
    class Client < PanamaxAgent::Client
      module File

        def create_file(repo, file_path, commit_message, file_object_for_content, branch=nil)
          opts = { file: file_object_for_content }
          opts[:branch] = branch if branch
          github_client.create_contents(repo, file_path, commit_message, nil, opts)
        end

        def get_file(repo, file_path, branch=nil)
          opts = { path: file_path }
          opts[:ref] = branch if branch
          github_client.contents(repo, opts)
        end

        def delete_file(repo, file_path, commit_message, branch=nil)
          resp = get_file(repo, file_path, branch)
          file_sha = resp.sha
          opts = {}
          opts[:branch] = branch if branch
          github_client.delete_contents(repo, file_path, commit_message, file_sha, opts)
        end

        def update_file(repo, file_path, commit_message, file_object_for_content, branch=nil)
          resp = get_file(repo, file_path, branch)
          file_sha = resp.sha
          opts = { file: file_object_for_content }
          opts[:branch] = branch if branch
          github_client.update_contents(repo, file_path, commit_message, file_sha, nil, opts)
        end

      end
    end
  end
end
