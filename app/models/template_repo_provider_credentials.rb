class TemplateRepoProviderCredentials

  attr_reader :account, :api_key

  def initialize(account, api_key)
    @account, @api_key = account, api_key
  end

end
