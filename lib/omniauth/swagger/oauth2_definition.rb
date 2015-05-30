module OmniAuth
  module Swagger

    class OAuth2Definition

      attr_reader :client_id, :client_secret, :client_options

      def initialize(security_def, options)
        @security_def, @options = security_def, options
      end

      def load_options(options)
        options[:client_id] = @options[:client_id]
        options[:client_secret] = @options[:client_secret]
        options[:client_options][:authorize_url] = @security_def.authorization_url
        options[:client_options][:token_url] = @security_def.token_url
        options[:scope] = @options[:scope]
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
    end

  end
end
