require 'omniauth-oauth2'
require 'omniauth/swagger/oauth2_definition'
require 'omniauth/swagger/default_provider_lookup'
require 'diesel'

module OmniAuth
  module Strategies

    class Swagger < OmniAuth::Strategies::OAuth2

      OPTION_UID = 'uid'.freeze
      OPTION_SPECIFICATION = 'specification'.freeze
      OPTION_SUBDOMAIN = 'subdomain'.freeze

      option :providers, nil
      option :provider_lookup, nil
      option :provider_param, 'provider'

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
        url + (url.index('?') ? '&' : '?') + "#{options[:provider_param]}=#{provider_name}"
      end

      uid do
        if uid_options.nil?
          raise "Missing #{OPTION_UID} setting for provider '#{provider_name}'"

        elsif uid_options.api?
          uid_options.
            api_value_path.
            split('.').
            reduce(raw_info) { |memo, key| memo[key] }.
            to_s

        elsif uid_options.access_token_param?
          access_token.params[uid_options.param]

        else
          raise "Unsupported UID option: #{uid_options.inspect}"
        end
      end

      extra do
        { "raw_info" => raw_info }
      end

      protected
        def provider_name
          @provider_name ||= request.params[options[:provider_param]].to_sym
        end

        def provider_options
          @provider_options ||= provider_lookup.get(provider_name, env)
        end

        def provider_lookup
          @provider_lookup ||= begin
                                 if lookup_opt = options[:provider_lookup]
                                   if lookup_opt.kind_of? Class
                                     lookup_opt.new
                                   else
                                     lookup_opt
                                   end
                                 else
                                   OmniAuth::Swagger::DefaultProviderLookup.new(options[:providers])
                                 end
                               end
        end

        def uid_options
          @uid_options ||= OmniAuth::Swagger::UIDOptions.from_options(provider_options[OPTION_UID])
        end

        def raw_info
          if uid_options
            api_options = {@definition.oauth2_key => {token: access_token.token}}
            if provider_options[OPTION_SUBDOMAIN]
              api_options[:subdomain] = provider_options[OPTION_SUBDOMAIN]
            end
            api_class = Diesel.build_api(specification)
            api = api_class.new(api_options)
            api.__send__(uid_options.api_operation, uid_options.api_params)
          else
            {}
          end
        end

        def load_definition
          specification.security_definitions.each_pair do |name, definition|
            if definition.type == 'oauth2'
              @definition = OmniAuth::Swagger::OAuth2Definition.new(definition, specification, provider_options)
            end
          end
          nil
        end

        def specification
          @specification ||= load_specification
        end

        def load_specification
          provider_options[OPTION_SPECIFICATION].call
        end

    end

  end
end

