require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Network
    class IPNetwork < Storm::Base::Model
      attr_accessor :broadcast
      attr_accessor :gateway
      attr_accessor :ip
      attr_accessor :netmask
      attr_accessor :reverse_dns

      def from_hash(h)
        super
        @broadcast = h[:broadcast]
        @gateway = h[:gateway]
        @ip = h[:ip]
        @netmask = h[:netmask]
        @reverse_dns = h[:reverse_dns]
      end

      # Add a number of IPs to an existing server
      #
      # @param server [Server] the specified server
      # @param ip_count [Int] ip count
      # @param reboot [Bool] if true, the server will be stopped, configured
      #                      the new IPs and then be rebooted
      # @return [String] a result message
      def self.add(server, ip_count, reboot=false)
        param = {}
        param[:uniq_id] = server.uniq_id
        param[:ip_count] = ip_count
        param[:reboot] = reboot ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/IP/add', param
        data[:adding]
      end

      # Get information about a particular IP.
      #
      # @param server [Server] the specified server
      # @param ip [String] IP address
      # @return [IPNetwork] a new IPNetwork object
      def self.details(server, ip)
        data = Storm::Base::SODServer.remote_call '/Network/IP/details',
                                                  :ip => ip,
                                                  :uniq_id => server.uniq_id
        ipnet = IPNetwork.new
        ipnet.from_hash data
        ipnet
      end

      # Get a list of all IPs for a particular server
      #
      # @param server [Server] the specified server
      # @param alsowith [String] one or an array of strings
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                IPNetwork objects)
      def self.list(server, alsowith, page_num, page_size)
        param = {}
        param[:uniq_id] = server.uniq_id
        param[:alsowith] = alsowith if alsowith
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        data = Storm::Base::SODServer.remote_call '/Network/IP/list', param
        res = {}
        res[:item_count] = data[:item_count]
        res[:item_total] = data[:item_total]
        res[:page_num] = data[:page_num]
        res[:page_size] = data[:page_size]
        res[:page_total] = data[:page_total]
        res[:items] = data[:items].map do |i|
          ipnet = IPNetwork.new
          ipnet.from_hash i
          ipnet
        end
        res
      end

      # Gets a list of public network asssignments for all subaccounts for a
      # particular account, optionally for a specific zone only.
      #
      # @param include_pools [Bool]
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @param zond_id [String] zone id
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                IPNetwork objects)
      def self.list_account_public(include_pools, page_num, page_size, zond_id)
        param = {}
        param[:include_pools] = include_pools ? 1 : 0
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        param[:zond_id] = zond_id if zond_id
        data = Storm::Base::SODServer.remote_call \
                    '/Network/IP/listAccntPublic', param
        res = {}
        res[:item_count] = data[:item_count]
        res[:item_total] = data[:item_total]
        res[:page_num] = data[:page_num]
        res[:page_size] = data[:page_size]
        res[:page_total] = data[:page_total]
        res[:items] = data[:items].map do |i|
          ipnet = IPNetwork.new
          ipnet.from_hash i
          ipnet
        end
        res
      end

      # Gets a paginated list os all public IPs for a particular server
      #
      # @param server [Server] the specified server
      # @param alsowith [String] one or an array of strings
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                IPNetwork objects)
      def self.list_public(server, alsowith, page_num, page_size)
        param = {}
        param[:uniq_id] = server.uniq_id
        param[:alsowith] = alsowith if alsowith
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        data = Storm::Base::SODServer.remote_call '/Network/IP/listPublic',
                                                  param
        res = {}
        res[:item_count] = data[:item_count]
        res[:item_total] = data[:item_total]
        res[:page_num] = data[:page_num]
        res[:page_size] = data[:page_size]
        res[:page_total] = data[:page_total]
        res[:items] = data[:items].map do |i|
          ipnet = IPNetwork.new
          ipnet.from_hash i
          ipnet
        end
        res
      end

      # Remove a specific IP from a server
      #
      # @param server [Server] the specified server
      # @param ip [String] the sepecified IP
      # @param reboot [Bool] if true, the server will be stopped, with the IP
      #                      removed and then be rebooted
      # @return [String] a result meessage
      def self.remove(server, ip, reboot=false)
        param = {}
        param[:uniq_id] = server.uniq_id
        param[:ip] = ip
        param[:reboot] = reboot ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/IP/remove', param
        data[:removing]
      end

      # Request additional IPs for a server
      #
      # @param server [Server] the specified server
      # @param ip_count [Int] ip count
      # @param usage_justification [String]
      # @return [String] a result message
      def self.request(server, ip_count, usage_justification)
        param = {}
        param[:uniq_id] = server.uniq_id
        param[:ip_count] = ip_count
        param[:usage_justification] = usage_justification if usage_justification
        data = Storm::Base::SODServer.remote_call '/Network/IP/request', param
        data[:adding]
      end
    end
  end
end
