class UsersController < ApplicationController

  rescue_from Faraday::Error::ConnectionFailed do |ex|
    handle_exception(ex, :github_connection_error)
  end

  def show
    respond_with User.instance
  end

  def update
    params[:subscribe] =
      params[:subscribe] == true ||
      params[:subscribe] == 'true' ||
      params[:subscribe] == 1 ||
      params[:subscribe] == '1'

    @user = User.instance
    @user.update_credentials_for(template_repo_provider, user_params)

    if template_repo_provider.valid?
      alias_kiss_user(@user.primary_email)
      @user.subscribe(@user.primary_email) if params[:subscribe]
    end

    respond_with @user
  end

  private

  def user_params
    params.permit(:account, :api_key, :github_access_token, :template_repo_provider)
  end

  def alias_kiss_user(email)
    KMTS.alias(panamax_id, email)
  rescue => ex
    logger.warn(ex.message)
  end

end
