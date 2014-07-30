class TemplatesController < ApplicationController

  def index
    respond_with Template.all
  end

  def show
    respond_with Template.find(params[:id])
  end

  def create
    respond_with TemplateBuilder.create(template_create_params), serializer: TemplateFileSerializer
  end

  def destroy
    respond_with Template.find(params[:id]).destroy
  end

  def save
    template = Template.find(params[:id])
    resp = template.save_to_repo(template_save_params)
    html_url = resp[:content][:html_url]
    render(nothing: true, location: html_url, status: :no_content)
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
        :command,
        volumes: [],
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
