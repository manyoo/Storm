require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class VPN < Storm::Base::Model
    attr_accessor :active
    attr_accessor :active_status
    attr_accessor :current_users
    attr_accessor :domain
    attr_accessor :max_users
    attr_accessor :network_range
    attr_accessor :region_id
    attr_accessor :vpn

    def from_hash(h)
      super
      @active = h[:active] == 0 ? false : true
      @active_status = h[:active_status]
      @current_users = h[:current_users]
      @domain = h[:domain]
      @max_users = h[:max_users]
      @network_range = h[:network_range]
      @region_id = h[:region_id]
      if h[:vpn]
        @vpn = VPN.new
        @vpn.from_hash h[:vpn]
      end
    end

    # Create a new VPN service
    #
    # @param domain [String]
    # @param features [Hash]
    # @param region_id [Int]
    # @param type [String]
    # @return [VPN] a new VPN object
    def self.create(domain, features, region_id, type)
      param = {}
      param[:domain] = domain
      param[:features] = features
      param[:region_id] = region_id
      param[:type] = type
      data = Storm::Base::SODServer.remote_call '/VPN/create', param
      vpn = VPN.new
      vpn.from_hash data
      vpn
    end

    # Get details information
    def details
      data = Storm::Base::SODServer.remote_call '/VPN/details',
                                                :uniq_id => self.uniq_id
      self.from_hash data
    end

    # Lists the authorized VPN users for a given account
    #
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @return [Hash]  a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                VPNUser objects)
    def list(page_num, page_size)
      param = {}
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      param[:uniq_id] = self.uniq_id
      Storm::Base::SODServer.remote_list '/VPN/list', param do |u|
        user = VPNUser.new
        user.from_hash u
        user
      end
    end

    # Update the features of a VPN service
    #
    # @param domain [String]
    # @param features [Hash]
    def update(domain, features)
      param = {}
      param[:domain] = domain
      param[:features] = features
      param[:uniq_id] = self.uniq_id
      data = Storm::Base::SODServer.remote_call '/VPN/update', param
      self.from_hash data
    end
  end

  class VPNUser < Storm::Base::Model
    attr_accessor :ip
    attr_accessor :netmask
    attr_accessor :user_id
    attr_accessor :username

    def from_hash(h)
      @ip = h[:ip]
      @netmask = h[:netmask]
      @user_id = h[:user_id]
      @username = h[:username]
    end
  end
end

