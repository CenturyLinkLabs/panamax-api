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

    user = User.instance
    user.update(user_params)

    user.subscribe if params[:subscribe] && user.valid?

    respond_with user
  end

  private

  def user_params
    params.permit(:github_access_token)
  end
end
