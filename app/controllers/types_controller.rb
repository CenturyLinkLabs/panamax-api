class TypesController < ApplicationController

  def index
    respond_with PanamaxApi::TYPES
  end
end
