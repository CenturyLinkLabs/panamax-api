module DeploymentTarget::Metadata
  extend ActiveSupport::Concern

  included do
    has_one :metadata, class_name: "DeploymentTargetMetadata", dependent: :destroy
  end

  def refresh_metadata
    with_remote_metadata_model do |metadata|
      resource = metadata.find
      create_metadata!(
        agent_version: resource.agent.version,
        adapter_version: resource.adapter.version,
        adapter_type: resource.adapter.type
      )
    end
  end

protected

  def with_remote_metadata_model
    Tempfile.open(name.to_s.downcase) do |file|
      file.write(public_cert)
      file.rewind
      yield(metadata_resource(file))
    end
  end

  def metadata_resource(cert_file)
    target = self

    Class.new(RemoteAgentMetadata) do
      include ActiveResource::Singleton

      self.site = target.endpoint_url
      self.element_name = 'metadata'
      self.user = target.username
      self.password = target.password

      self.ssl_options = {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: cert_file.path
      } unless Rails.env.development?

      # The combination of a singleton and an anonymous class causes
      # ActiveResource to need some handholding.
      def self.model_name
        ActiveModel::Name.new(RemoteAgentMetadata, nil, "Metadata")
      end
    end
  end
end
