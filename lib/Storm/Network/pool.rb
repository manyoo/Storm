require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/Server/server"
require "Storm/Network/zone"

module Storm
  module Network
    class Assignment < Storm::Base::Model
      attr_accessor :begin_range
      attr_accessor :broadcast
      attr_accessor :end_range
      attr_accessor :gateway
      attr_accessor :netmask
      attr_accessor :zone

      def from_hash(h)
        super
        @begin_range = h[:begin_range]
        @broadcast = h[:broadcast]
        @end_range = h[:end_range]
        @gateway = h[:gateway]
        @netmask = h[:netmask]
        @zone = Storm::Network::Zone.new
        @zone.uniq_id = h[:zone_id]
      end
    end

    class Pool < Storm::Base::Model
      attr_accessor :account
      attr_accessor :assignments
      attr_accessor :server
      attr_accessor :zone

      def from_hash(h)
        self.uniq_id = h[:id]
        @account = h[:accnt]
        @assignments = Assignment.new
        @assignments.from_hash h[:assignments]
        @server = Storm::Server::Server.new
        @server.uniq_id = h[:uniq_id]
        @zone = Storm::Network::Zone.new
        @zone.uniq_id = h[:zone_id]
      end

      # Create a new IP Pool
      #
      # @param add_ips [Array] an array of IP addresses
      # @param new_ips [Int] number of new IPs
      # @param zone [Zone] a network zone
      # @return [Pool] a new Pool object
      def self.create(add_ips, new_ips, zone)
        if add_ips == nil and new_ips == 0
          raise 'Either add_ips or new_ips must be provided'
        end
        param = {}
        param[:add_ips] = add_ips if add_ips
        param[:new_ips] = new_ips if new_ips
        param[:zone_id] = zone.uniq_id
        data = Storm::Base::SODServer.remote_call '/Network/Pool/create', param
        pool = Pool.new
        pool.from_hash data
        pool.zone = zone
        pool
      end

      # Delete the current pool and all the assignments that are only in the
      # pool.
      #
      # @return [String] a result message
      def delete
        data = Storm::Base::SODServer.remote_call '/Network/Pool/delete',
                                                  :uniq_id => self.uniq_id
        data[:deleted]
      end

      # Delete a pool and all the assignments that are only in the pool
      #
      # @param subaccnt [Int] sub account number
      # @return [String] a result message
      def self.delete(subaccnt)
        data = Storm::Base::SODServer.remote_call '/Network/Pool/delete',
                                                  :subaccnt => subaccnt
        data[:deleted]
      end

      # Get the details of the IP Pool
      #
      # @param free_only [Bool]
      def details(free_only)
        free = free_only ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/Pool/details',
                                                  :id => self.uniq_id,
                                                  :free_only => free
        self.from_hash data
      end

      # Get a list of network assignments for a particular IP pool
      #
      # @param zone [Zone] a zone object
      # @param alsowith [String/Array] one or an array of strings
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Assignment objects)
      def self.list(zone, alsowith, page_num, page_size)
        param = {}
        param[:zone_id] = zone.uniq_id if zone
        param[:alsowith] = alsowith if alsowith
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        Storm::Base::SODServer.remote_list '/Network/Pool/list', param do |i|
          asgnm = Assignment.new
          asgnm.from_hash i
          asgnm
        end
      end

      # Update the IP Pool
      #
      # @param add_ips [Array] an array of IPs to add
      # @param remove_ips [Array] an array of IPs to remove
      # @param new_ips [Int] number of new IPs
      def update(add_ips, remove_ips, new_ips)
        param = {}
        param[:id] = self.uniq_id
        param[:add_ips] = add_ips if add_ips
        param[:remove_ips] = remove_ips if remove_ips
        param[:new_ips] = new_ips if new_ips
        data = Storm::Base::SODServer.remote_call '/Network/Pool/update', param
        self.from_hash data
      end
    end
  end
end
