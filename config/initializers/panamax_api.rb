require 'yaml'
module PanamaxApi
  TYPES = YAML.load_file('config/types.yml')

  def self.ssl_certs_dir
    'certs/'
  end
end
