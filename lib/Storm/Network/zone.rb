require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Network
    class ZoneRegion < Storm::Base::Model
      attr_accessor :name

      def from_hash(h)
        super
        @name = h[:name]
      end
    end

    class ZoneHVS < Storm::Base::Model
      attr_accessor :kvm
      attr_accessor :xen

      def from_hash(h)
        @kvm = h[:kvm] ? true : false
        @xen = h[:xen] ? true : false
      end
    end

    class Zone < Storm::Base::Model
      attr_accessor :is_default
      attr_accessor :name
      attr_accessor :region
      attr_accessor :status
      attr_accessor :valid_source_hvs

      def from_hash(h)
        super
        @is_default = h[:is_default] ? true : false
        @name = h[:name]
        @region = ZoneRegion.new
        @region.from_hash h[:region]
        @status = h[:status]
        @valid_source_hvs = ZoneHVS.new
        @valid_source_hvs.from_hash h[:valid_source_hvs]
      end

      # Get details of a the current zone
      def details
        data = Storm::Base::SODServer.remote_call '/Netowrk/Zone/details',
                                                  :id => self.uniq_id
        self.from_hash data
      end

      # Get a list of Zones
      #
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @param region [String] region name
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Zone objects)
      def self.list(page_num=0, page_size=0, region=nil)
        param = {}
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        param[:region] = region if region
        data = Storm::Base::SODServer.remote_call '/Network/Zone/list', param
        res = {}
        res[:item_count] = data[:item_count]
        res[:item_total] = data[:item_total]
        res[:page_num] = data[:page_num]
        res[:page_size] = data[:page_size]
        res[:page_total] = data[:page_total]
        res[:items] = data[:items].map do |i|
          zone = Zone.new
          zone.from_hash i
          zone
        end
        res
      end

      # Set the current zone as the default
      def set_default
        Storm::Base::SODServer.remote_call '/Network/Zone/setDefault',
                                           :id => self.uniq_id
      end
    end
  end
end
