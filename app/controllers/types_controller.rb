class TypesController < ApplicationController
  respond_to :json

  def index
    respond_with PanamaxApi::TYPES.map { |type| { name: type } }
  end
end
