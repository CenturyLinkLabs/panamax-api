class TemplatesController < ApplicationController
  respond_to :json

  def index
    respond_with Template.all
  end

  def show
    respond_with Template.find(params[:id])
  end

  def create
    respond_with TemplateBuilder.create(template_create_params[:template])
  end

  def save
    template = Template.find(params[:id])
    resp = template.save_to_repo(template_save_params)
    html_url = resp[:content][:html_url]
    render(nothing: true, location: html_url, status: :no_content)
  rescue => ex
    render(json: { error: ex.message }, status: :internal_server_error)
  end

  private

  def template_create_params
    params.permit(template: [
        :app_id,
        :name,
        :description,
        :keywords,
        :icon,
        :documentation,
        authors: []
    ])
  end

  def template_save_params
    params.permit(
      :repo,
      :file_name
    )
  end

end
