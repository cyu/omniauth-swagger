module OmniAuth
  module Swagger
    class UIDOptions

      OPTION_API = 'api'.freeze
      OPTION_API_PARAMS = 'api_params'.freeze
      OPTION_PARAM = 'param'.freeze

      attr_accessor :api, :api_params, :param

      def self.from_options(opts)
        return nil if opts.nil?
        unless opts.kind_of?(Hash)
          opts = {OPTION_API => opts}
        end
        uid_options = new
        uid_options.api = opts[OPTION_API]
        uid_options.api_params = opts[OPTION_API_PARAMS]
        uid_options.param = opts[OPTION_PARAM]
        uid_options
      end

      def api?
        api != nil
      end

      def access_token_param?
        param != nil
      end

      def api_value_path
        @api_value_path ||= api.split("#")[1]
      end

      def api_operation
        @api_operation ||= api.split("#").first
      end

      def api_params
        @api_params || {}
      end

    end
  end
end
