require 'omniauth-oauth2'
require 'open-uri'
require 'omniauth/swagger/oauth2_definition'
require 'diesel'

module OmniAuth
  module Strategies

    class Swagger < OmniAuth::Strategies::OAuth2

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
        url + (url.index('?') ? '&' : '?') + "provider=#{request.params['provider']}"
      end

      uid do
        uid_option = provider_options[:uid]
        if uid_option.kind_of? Hash
          if uid_option[:api]
            uid_from_api(uid_option[:api])
          else
            raise "Unsupported UID option: #{uid_option.inspect}"
          end
        else
          uid_from_api(uid_option)
        end
      end

      protected
        def provider_options
          @provider_options ||= options[:providers][request.params['provider']]
        end

        def uid_from_api(signature)
          operation, key = signature.split('#')
          raw_info[key].to_s
        end

        def raw_info
          api_class = Diesel.build_api(specification)
          api = api_class.new(@definition.oauth2_key => {token: access_token.token})
          operation, key = provider_options[:uid].split('#')
          api.__send__(operation, {})
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
          uri = provider_options[:uri]
          spec = nil
          open(uri) do |f|
            spec = Diesel::Swagger::Parser.new.parse(f)
          end
          spec
        end

    end

  end
end

