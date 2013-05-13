require "Storm/Base/sodserver"

module Storm
  module Utilities
    module Info
      # This method can be used as a basic check to see if communication with
      # the api is possible
      #
      # @return [String] a ping message
      def self.ping
        data = Storm::Base::SODServer.remote_call '/Utilities/Info/ping'
        data[:ping]
      end

      # Returns the version of the api you are using
      #
      # @return [String] version
      def self.version
        data = Storm::Base::SODServer.remote_call '/Utilities/Info/version'
        data[:version]
      end
    end
  end
end
