require 'omniauth-oauth2'
require 'open-uri'
require 'omniauth/swagger/oauth2_definition'
require 'diesel'
require 'yaml'

module OmniAuth
  module Strategies

    class Swagger < OmniAuth::Strategies::OAuth2

      OPTION_UID = 'uid'.freeze
      OPTION_UID_API = 'api'.freeze
      OPTION_UID_PARAM = 'param'.freeze
      OPTION_URI = 'uri'.freeze

      PARAM_PROVIDER = 'provider'.freeze

      option :providers, {}

      def setup_phase
        load_definition
        @definition.load_options(options)
        super
      end

      def authorize_params
        super.tap do |params|
          passthru_params = @definition.authorize_params || []
          if @definition.scopes != nil && @definition.scopes.any?
            passthru_params << 'scope'
          end
          passthru_params.each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      def callback_url
        url = super
        url + (url.index('?') ? '&' : '?') + "provider=#{provider_name}"
      end

      uid do
        if uid_api
          operation, key = uid_api.split('#')
          raw_info[key].to_s
        else
          uid_option = provider_options[OPTION_UID]
          if uid_option[OPTION_UID_PARAM]
            access_token.params[uid_option[OPTION_UID_PARAM]]
          else
            raise "Unsupported UID option: #{uid_option.inspect}"
          end
        end
      end

      protected
        def provider_name
          @provider_name ||= request.params[PARAM_PROVIDER].to_sym
        end

        def provider_options
          @provider_options ||= begin
                                  defaults = provider_defaults[provider_name] || {}
                                  defaults.merge(options[:providers][provider_name])
                                end
        end

        def provider_defaults
          @provider_defaults ||= YAML.load_file(File.join(File.dirname(__FILE__), 'swagger_providers.yml'))
        end

        def uid_api
          opt = provider_options[OPTION_UID]
          opt.kind_of?(Hash) ? opt[OPTION_UID_API] : opt
        end

        def raw_info
          if uid_api
            api_class = Diesel.build_api(specification)
            api = api_class.new(@definition.oauth2_key => {token: access_token.token})
            operation, key = uid_api.split('#')
            api.__send__(operation, {})
          else
            {}
          end
        end

        def load_definition
          specification.security_definitions.each_pair do |name, definition|
            if definition.type == 'oauth2'
              @definition = OmniAuth::Swagger::OAuth2Definition.new(definition, provider_options)
            end
          end
          nil
        end

        def specification
          @specification ||= load_specification
        end

        def load_specification
          uri = provider_options[OPTION_URI]
          spec = nil
          open(uri) do |f|
            spec = Diesel::Swagger::Parser.new.parse(f)
          end
          spec
        end

    end

  end
end

