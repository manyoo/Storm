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
        @kvm = h[:kvm].to_i == 1 ? true : false
        @xen = h[:xen].to_i == 1 ? true : false
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
        @is_default = h[:is_default].to_i == 1 ? true : false
        @name = h[:name]
        @region = ZoneRegion.new
        @region.from_hash h[:region]
        @status = h[:status]
        @valid_source_hvs = ZoneHVS.new
        @valid_source_hvs.from_hash h[:valid_source_hvs]
      end

      # Get details of a the current zone
      def details
        data = Storm::Base::SODServer.remote_call '/Network/Zone/details',
                                                  :id => self.uniq_id
        self.from_hash data
      end

      # Get a list of Zones
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number
      #  :page_size [Int] page size
      #  :region [String] region name
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Zone objects)
      def self.list(options={})
        Storm::Base::SODServer.remote_list '/Network/Zone/list', options do |i|
          zone = Zone.new
          zone.from_hash i
          zone
        end
      end

      # Set the current zone as the default
      def set_default
        Storm::Base::SODServer.remote_call '/Network/Zone/setDefault',
                                           :id => self.uniq_id
      end
    end
  end
end
