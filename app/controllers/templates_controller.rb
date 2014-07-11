class TemplatesController < ApplicationController
  respond_to :json

  def index
    respond_with Template.all
  end

  def show
    respond_with Template.find(params[:id])
  end

  def create
    respond_with TemplateBuilder.create(template_create_params), serializer: TemplateFileSerializer
  rescue => ex
    render(json: { error: ex.message }, status: :internal_server_error)
  end

  def destroy
    respond_with Template.find(params[:id]).destroy
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
    params.permit(
      :app_id,
      :name,
      :description,
      :keywords,
      :type,
      :documentation,
      :fig_yml,
      authors: [],
      images: [[
        :name,
        :source,
        :description,
        :template_id,
        :category,
        :type,
        volumes: [],
        command: [],
        expose: [],
        links: [[:service_id, :alias]],
        environment: [[:variable, :value, :required]],
        links: [[:service_id, :alias]],
        ports: [[:host_interface, :host_port, :container_port, :proto]]
      ]]
    )
  end

  def template_save_params
    params.permit(
      :repo,
      :file_name
    )
  end

end
