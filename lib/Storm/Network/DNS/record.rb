require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/Network/DNS/zone"

module Storm
  module Network
    module DNS
      class RecordRegion < Storm::Base::Model
        attr_accessor :rdata
        attr_accessor :region_name
        attr_accessor :region_id

        def from_hash(h)
          @rdata = h[:rdata]
          @region_name = h[:region]
          @region_id = h[:region_id]
        end

        def to_hash
          res = {}
          res[:rdata] = @rdata
          res[:region] = @region_name
          res[:region_id] = @region_id
          res
        end

        # Add a new region to a DNS record
        #
        # @param rdata [String]
        # @param record [Record] a record object
        # @param region [String]
        # @param region_id [Int]
        def self.create(rdata, record, region, region_id)
          param = {}
          param[:rdata] = rdata
          param[:record_id] = record.uniq_id
          param[:region] = region if region
          param[:region_id] = region_id if region_id
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Record/Region/create', param
          record.from_hash data
        end

        # Delete a region from the specified DNS record
        #
        # @param record [Record] DNS record
        # @param region [String]
        # @param region_id [Int]
        # @return [Hash] a hash with keys: :accnt, :record_id, :region_id
        def self.delete(record, region, region_id)
          param = {}
          param[:record_id] = record.uniq_id
          param[:region] = region if region
          param[:region_id] = region_id if region_id
          Storm::Base::SODServer.remote_call \
               '/Network/DNS/Record/Region/delete', param
        end

        # Update regions associated with DNS records
        #
        # @param rdata [String]
        # @param record [Record] a record object
        # @param region [String]
        # @param region_id [Int]
        def self.update(rdata, record, region, record_id)
          param = {}
          param[:rdata] = rdata
          param[:record_id] = record.uniq_id
          param[:region] = region if region
          param[:region_id] = region_id if region_id
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Record/Region/update', param
          record.from_hash data
        end
      end

      class Record < Storm::Base::Model
        attr_accessor :admin_email
        attr_accessor :expiry
        attr_accessor :full_data
        attr_accessor :minimum
        attr_accessor :name
        attr_accessor :nameserver
        attr_accessor :port
        attr_accessor :prio
        attr_accessor :rdata
        attr_accessor :refresh_interval
        attr_accessor :region_overrides
        attr_accessor :retry
        attr_accessor :serial
        attr_accessor :target
        attr_accessor :ttl
        attr_accessor :type
        attr_accessor :weight
        attr_accessor :zone

        def from_hash(h)
          super
          @admin_email = h[:adminEmail]
          @expiry = h[:expiry]
          @full_data = h[:fullData]
          @minimum = h[:minimum]
          @name = h[:name]
          @nameserver = h[:nameserver]
          @port = h[:port]
          @prio = h[:prio]
          @rdata = h[:rdata]
          @refresh_interval = h[:refreshInterval]
          @region_overrides = h[:regionOverrides].map do |r|
            region = RecordRegion.new
            region.from_hash r
            region
          end
          @retry = h[:retry]
          @serial = h[:serial]
          @target = h[:target]
          @ttl = h[:ttl]
          @type = h[:type]
          @weight = h[:weight]
          @zone = Storm::Network::DNS::Zone.new
          @zone.uniq_id = h[:zone_id]
        end

        # Create a new resource recrod to a zone file
        #
        # @param name [String]
        # @param prio [Int]
        # @param rdata [String]
        # @param region_overrides [Array] an array of RecordRegion objects
        # @param ttl [Int]
        # @param type [String] One of 'A', 'TXT', 'CNAME', 'NS', 'SOA', 'MX',
        #                      'PTR', 'SRV', 'AAAA'
        # @param zone [Zone]
        # @return [Record] a new Record object
        def self.create(name, prio, rdata, region_overrides, ttl, type, zone)
          param = {}
          param[:name] = name
          param[:prio] = prio
          param[:rdata] = rdata
          param[:region_overrides] = region_overrides.map { |i| i.to_hash }
          param[:ttl] = ttl if ttl
          param[:type] = type
          param[:zone_id] = zone.uniq_id
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Record/create', param
          rec = Record.new
          rec.from_hash data
          rec
        end

        # Delete the record
        #
        # @return [Int] the deleted record id
        def delete
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Record/delete', :id => self.uniq_id
          data[:deleted]
        end

        # Get details information of the current record
        def details
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Record/details', :id => self.uniq_id
          self.from_hash data
        end

        # Get a list of records from a zone file
        #
        # @param zone [Zone]
        # @param page_num [Int] page number
        # @param page_size [Int] page size
        # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
        #                :page_size, :page_total and :items (an array of
        #                Record objects)
        def self.list(zone, page_num, page_size)
          param = {}
          param[:zone_id] = zone.uniq_id
          param[:page_num] = page_num if page_num
          param[:page_size] = page_size if page_size
          Storm::Base::SODServer.remote_list '/Network/DNS/Record/list',
                                             param do |r|
                                              record = Record.new
                                              record.from_hash r
                                              record
                                            end
        end

        # Update a resource record
        #
        # @param prio [Int]
        # @param rdata [String]
        # @param ttl [Int]
        def update(prio, rdata, ttl)
          param = {}
          param[:id] = self.uniq_id
          param[:rdata] = rdata if ttl
          param[:ttl] = ttl if ttl
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Record/update', param
          self.from_hash data
        end
      end
    end
  end
end