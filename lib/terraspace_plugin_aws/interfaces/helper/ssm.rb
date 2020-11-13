require "base64"

module TerraspacePluginAws::Interfaces::Helper
  class SSM
    include TerraspacePluginAws::Clients
    include TerraspacePluginAws::Logging

    def initialize(options={})
      @options = options
      @base64 = options[:base64]
    end

    def fetch(name)
      value = fetch_value(name)
      value = Base64.strict_encode64(value).strip if @base64
      value
    end

    def fetch_value(name)
      resp = ssm.get_parameter(name: name, with_decryption: true)
      resp.parameter.value
    rescue Aws::SSM::Errors::ParameterNotFound => e
      logger.info "WARN: name #{name} not found".color(:yellow)
      logger.info e.message
      "NOT FOUND #{name}" # simple string so tfvars valid
    end
  end
end
