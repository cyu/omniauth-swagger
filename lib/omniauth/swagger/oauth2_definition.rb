module OmniAuth
  module Swagger

    class OAuth2Definition

      OPTION_CLIENT_ID = 'client_id'.freeze
      OPTION_CLIENT_SECRET = 'client_secret'.freeze
      OPTION_AUTHORIZE_URL = 'authorize_url'.freeze
      OPTION_TOKEN_URL = 'token_url'.freeze
      OPTION_SCOPE = 'scope'.freeze
      OPTION_SUBDOMAIN = 'subdomain'.freeze

      attr_reader :client_id, :client_secret, :client_options

      def initialize(security_def, spec, options)
        @security_def, @spec, @options = security_def, spec, options
      end

      def load_options(options)
        options[:client_id] = @options[OPTION_CLIENT_ID]
        options[:client_secret] = @options[OPTION_CLIENT_SECRET]
        options[:client_options][OPTION_AUTHORIZE_URL] = prepare_url(@security_def.authorization_url)
        options[:client_options][OPTION_TOKEN_URL] = prepare_url(@security_def.token_url)
        options[:scope] = @options[OPTION_SCOPE]
      end

      def oauth2_key
        @security_def.id.to_sym
      end

      def scopes
        @security_def.scopes ? @security_def.scopes.keys : []
      end

      def authorize_params
        @security_def.extensions[:authorize_parameters]
      end

      protected

        def prepare_url(url)
          if (base_host = @spec.extensions[:base_host]) &&
              (subdomain = @options[OPTION_SUBDOMAIN]) &&
              !url.match(/^https?\/\//)
            "https://#{subdomain}.#{base_host}#{url}"
          else
            url
          end
        end
    end

  end
end
