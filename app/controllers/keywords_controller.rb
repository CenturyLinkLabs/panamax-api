class KeywordsController < ApplicationController

  respond_to :json

  def index
    respond_with Template.all_keywords
  end
end
