require 'yaml'

module OmniAuth
  module Swagger

    module ProviderDefaults
      def provider_defaults
        @provider_defaults ||= YAML.load_file(defaults_file)
      end

      def defaults_file
        File.join(File.dirname(__FILE__), 'providers.yml')
      end
    end

  end
end
