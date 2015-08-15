require 'omniauth/swagger/provider_defaults'
require 'open-uri'

module OmniAuth
  module Swagger

    class DefaultProviderLookup
      include ProviderDefaults

      OPTION_URI = 'uri'.freeze

      def initialize(providers_config)
        @config = providers_config
      end

      def get(provider_name, env)
        defaults = provider_defaults[provider_name] || {}
        if cfg = @config[provider_name]
          opts = defaults.merge(cfg)
          configure_spec_loader(opts)
          opts
        else
          defaults
        end
      end

      protected
        def configure_spec_loader(opts)
          uri = opts.delete(OPTION_URI)
          opts[OmniAuth::Strategies::Swagger::OPTION_SPECIFICATION] = Proc.new{
            spec = nil
            open(uri) do |f|
              spec = Diesel::Swagger::Parser.new.parse(f)
            end
            spec
          }
        end
    end

  end
end
