class UsersController < ApplicationController
  respond_to :json

  def show
    respond_with User.instance
  end

  def update
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
