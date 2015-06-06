require 'yaml'

module OmniAuth
  module Swagger

    class DefaultProviderLookup

      def initialize(providers_config)
        @config = providers_config
      end

      def provider_defaults
        @provider_defaults ||= YAML.load_file(defaults_file)
      end

      def defaults_file
        File.join(File.dirname(__FILE__), 'providers.yml')
      end

      def get(provider_name)
        defaults = provider_defaults[provider_name] || {}
        if cfg = @config[provider_name]
          defaults.merge(cfg)
        else
          defaults
        end
      end
    end

  end
end
