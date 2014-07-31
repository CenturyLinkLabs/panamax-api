module GithubAccessTokenOverride
  refine User do
    def github_access_token
      '4afd3519b925cd38bb1b04398de783266859ca47'
    end
  end
end
