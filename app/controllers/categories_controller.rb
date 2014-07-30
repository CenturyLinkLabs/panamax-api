class CategoriesController < ApplicationController

  def index
    respond_with app.categories
  end

  def show
    respond_with app.categories.find(params[:id])
  end

  def create
    category = app.categories.create(category_params)
    respond_with app, category
  end

  def update
    category = app.categories.find(params[:id])
    category.update(category_params)
    respond_with app, category
  end

  def destroy
    category = app.categories.destroy(params[:id])
    respond_with app, category
  end

  private

  def app
    @app ||= App.find(params[:app_id])
  end

  def category_params
    params.permit(:name, :position)
  end
end
