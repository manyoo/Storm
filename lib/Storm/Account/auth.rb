require "Storm/Base/sodserver"

module Storm
  module Account
    module Auth
      # Expire an existing token immediately
      #
      # @return [Bool] whether the token is expired
      def self.expire
        data = Storm::Base::SODServer.remote_call '/Account/Auth/expireToken'
        data[:expired] == 0 ? false : true
      end

      # Tokens can be kept alive by calling this method again before the token
      # expires, up to a maximum of 12 hours.  After 12 hours, the token will
      # be expired permanently and a new token will need to be retrieved using
      # the original password for your user.
      #
      # @param timeout [Int]
      # @return [Hash] a hash with keys: :expires and :token
      def self.token(timeout)
        Storm::Base::SODServer.remote_call '/Account/Auth/token',
                                           :timeout => timeout
      end
    end
  end
end
