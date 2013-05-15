require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Storage
    class Zone < Storm::Base::Model
      attr_accessor :name

      def from_hash(h)
        super
        @name = h[:name]
      end
    end

    class Cluster < Storm::Base::Model
      attr_accessor :description
      attr_accessor :zone

      def from_hash(h)
        super
        @description = h[:description]
        @zone = Zone.new
        @zone.from_hash h[:zone]
      end

      # Get a paginated list of block storage clusters, including the zone that
      # the cluster is in.
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Cluster objects)
      def self.list(options)
        Storm::Base::SODServer.remote_list \
                  '/Storage/Block/Cluster/list', options do |i|
          cluster = Cluster.new
          cluster.from_hash i
          cluster
        end
      end
    end
  end
end
