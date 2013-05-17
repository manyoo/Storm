require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/Network/zone"

module Storm
  module Storage
    # This class defines APIs for listing block storage clusters
    class Cluster < Storm::Base::Model
      attr_accessor :description
      attr_accessor :id
      attr_accessor :zone

      def from_hash(h)
        @description = h[:description]
        @id = h[:id]
        @zone = Storm::Network::Zone.new
        if h[:zone]
          @zone.from_hash h[:zone]
        end
      end

      # Get a paginated list of block storage clusters, including the zone that
      # the cluster is in.
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number,
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Cluster objects)
      def self.list(options={})
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
