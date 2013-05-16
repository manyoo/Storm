require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/server"
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
        @server = Storm::Server.new
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
      # @param options [Hash] optional keys:
      #  :free_only [Bool]
      def details(options={})
        param = {
          :id => self.uniq_id,
          :free_only => false
        }.merge options
        param[:free_only] = param[:free_only] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/Pool/details',
                                                  param
        self.from_hash data
      end

      # Get a list of network assignments for a particular IP pool
      #
      # @param options [Hash] optional keys:
      #  :zone [Zone] a zone object
      #  :alsowith [String/Array] one or an array of strings
      #  :page_num [Int] page number
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Assignment objects)
      def self.list(options={})
        if options[:zone]
          options[:zone_id] = options[:zone].uniq_id
          options.delete :zond
        end
        Storm::Base::SODServer.remote_list '/Network/Pool/list', options do |i|
          asgnm = Assignment.new
          asgnm.from_hash i
          asgnm
        end
      end

      # Update the IP Pool
      #
      # @param options [Hash] optional keys:
      #  :add_ips [Array] an array of IPs to add
      #  :remove_ips [Array] an array of IPs to remove
      #  :new_ips [Int] number of new IPs
      def update(options={})
        param = { :id => self.uniq_id }.merge options
        data = Storm::Base::SODServer.remote_call '/Network/Pool/update', param
        self.from_hash data
      end
    end
  end
end
