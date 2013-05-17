require "Storm/Base/sodserver"

module Storm
  module Account
    # This Module contains methods to update and use an account's
    # authentication credentials
    module Auth
      @@username = nil
      @@password = nil
      @@token = nil

      # Get the API account user name
      #
      # @return [String]
      def self.username
        @@username
      end

      # Set the API account user name
      #
      # @param name [String]
      def self.username=(name)
        @@username = name
      end

      # Get the API account password
      #
      # @return [String]
      def self.password
        @@password
      end

      # Set the API account password
      #
      # @param pass [String]
      def self.password=(pass)
        @@password = pass
      end

      # Get the current API token
      #
      # @return [String]
      def self.token_string
        @@token
      end

      # Expire an existing token immediately
      #
      # @return [Bool] whether the token is expired
      def self.expire
        data = Storm::Base::SODServer.remote_call '/Account/Auth/expireToken'
        @@token = nil
        data[:expired].to_i == 1 ? true : false
      end

      # Tokens can be kept alive by calling this method again before the token
      # expires, up to a maximum of 12 hours.  After 12 hours, the token will
      # be expired permanently and a new token will need to be retrieved using
      # the original password for your user.
      #
      # @param options [Hash] with keys:
      #                :timeout [Int]
      # @return [Hash] a hash with keys: :expires and :token
      def self.token(options={})
        data = Storm::Base::SODServer.remote_call '/Account/Auth/token',
                                                  options
        @@token = data[:token]
        data
      end
    end
  end
end
