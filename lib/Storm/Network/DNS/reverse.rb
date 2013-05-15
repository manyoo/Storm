require "Storm/Base/sodserver"

module Storm
  module Network
    module DNS
      module Reverse
        # Remove a reverse DNS record
        #
        # @param ip [String]
        # @param options [Hash] optional keys:
        #  :hostname [String]
        # @return [String] the deleted IP address
        def self.delete(ip, options)
          param = { :ip => ip }.merge options
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Reverse/delete', param
          data[:deleted]
        end

        # Update a record
        #
        # @param ip [String]
        # @param hostname [String]
        # @return [Hash] a hash with IP as keys and domain name as values
        def self.update(ip, hostname)
          Storm::Base::SODServer.remote_call \
               '/Network/DNS/Reverse/update', :ip => ip, :hostname => hostname
        end
      end
    end
  end
end
