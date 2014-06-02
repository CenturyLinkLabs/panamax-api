require 'base64'
require 'octokit'

class TemplateRepo
  class GithubRepoFileEnumerator
    include Enumerable

    def initialize(repo_name)
      @repo_name = repo_name
    end

    def each
      tree_from_reference.each do |node|
        # Looking only at blobs, not sub-trees
        next unless node.type == 'blob'
        yield blob(node)
      end
    end

    private

    def blob(node)
      lazily_loaded_blob_class.new(node, @repo_name, github_client)
    end

    def tree_from_reference(ref='/heads/master')
      # Look-up named reference
      ref = github_client.ref(@repo_name, ref)

      # Retrieve reference's commit
      commit_sha = ref.object.sha
      commit = github_client.commit(@repo_name, commit_sha)

      # Find tree associated w/ commit
      tree_sha = commit.commit.tree.sha
      tree = github_client.tree(@repo_name, tree_sha)

      tree.tree
    end

    def github_client
      @client ||=
        Octokit::Client.new(access_token: User.instance.github_access_token)
    end

    def lazily_loaded_blob_class
      @blob_class ||= Class.new do

        attr_reader :name, :size

        def initialize(node, repo, client)
          @name = node.path
          @size = node.size
          @sha = node.sha
          @repo = repo
          @client = client
        end

        def content
          blob = @client.blob(@repo, @sha)
          Base64.decode64(blob.content)
        end

        def inspect
          "#<Blob name: \"#{@name}\", sha: \"#{@sha}\">"
        end
      end
    end
  end
end
