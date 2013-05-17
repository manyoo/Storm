require 'Storm/Base/model'
require 'Storm/Base/sodserver'

module Storm
  module InternalServer
    class VirtualDomain < Storm::Base::Model
      attr_accessor :active
      attr_accessor :active_status
      attr_accessor :custom
      attr_accessor :domain
      attr_accessor :ip
      attr_accessor :managed
      attr_accessor :region_id
      attr_accessor :server
      attr_accessor :uniq_id
      attr_accessor :username

      def from_hash(h)
        @active = h[:active]
        @active_status = h[:activeStatus]
        @custom = h[:custom]
        @domain = h[:domain]
        @ip = h[:ip]
        @managed = h[:managed]
        @region_id = h[:region_id]
        @server = h[:server]
        @uniq_id = h[:uniq_id]
        @username = h[:username]
      end

      # Create a new add-on domain for a shared subaccnt
      #
      # @param domain [String] a hostname or fully-qualified domain name
      # @param server [Server] an existing Server object
      # @return [Bool] a boolean value indicating if the operation succeed
      def self.create(domain, server)
        param = {}
        param[:domain] = domain
        param[:uniq_id] = server.uniq_id
        data = Storm::Base::SODServer.remote_call \
                  '/Server/VirtualDomain/create', param
        data[:success].to_i == 1 ? true : false
      end

      # Returns the number of free VIRs a given type of shared account receives
      #
      # @param type [String] A valid product code
      # @return [Hash] a hash with keys: :count and :type
      def self.free_count(type)
        Storm::Base::SODServer.remote_call '/Server/VirtualDomain/freeCount',
                                           :type => type
      end

      # Lists the domains for a given server
      #
      # @param server [Server] an existing server object
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                VirtualDomain objects)
      def self.list(server, options={})
        param = { :uniq_id => server.uniq_id }.merge options
        Storm::Base::SODServer.remote_list '/Server/VirtualDomain/list',
                                                  param do |i|
          vd = VirtualDomain.new
          vd.from_hash i
          vd
        end
      end

      # Lists the domains for in an account that are not linked to a server
      #
      # @param options [Hash] optional keys:
      # :page_num [Int] page number
      # :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                VirtualDomain objects)
      def self.list_orphans(options={})
        Storm::Base::SODServer.remote_list \
                     '/Server/VirtualDomain/listOrphans', options do |i|
          vd = VirtualDomain.new
          vd.from_hash i
          vd
        end
      end

      # Links an existing orphaned add-on domain to a shared subaccnt
      #
      # @param owner [String] an identifier
      # @param server [Server] an existing server object
      # @return [Bool] a boolean value indicating if the operation succeed
      def self.relink(owner, server)
        param = {}
        param[:owner] = owner
        param[:uniq_id] = server.uniq_id
        data = Storm::Base::SODServer.remote_call \
                      '/Server/VirtualDomain/relink', param
        data[:success].to_i == 1 ? true : false
      end
    end
  end
end
