require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Network
    module DNS
      class ZoneData < Storm::Base::Model
        attr_accessor :contact
        attr_accessor :ip
        attr_accessor :primary
        attr_accessor :secondary

        def from_hash(h)
          @contact = h[:contact]
          @ip = h[:ip]
          @primary = h[:primary]
          @secondary = h[:secondary]
        end

        def to_hash
          res = {}
          res[:contact] = @contact
          res[:ip] = @ip
          res[:primary] = @primary
          res[:secondary] = @secondary
          res
        end
      end

      class Zone < Storm::Base::Model
        attr_accessor :active
        attr_accessor :delegation_checked
        attr_accessor :delegation_status
        attr_accessor :master
        attr_accessor :name
        attr_accessor :notified_serial
        attr_accessor :region_support
        attr_accessor :registering
        attr_accessor :type

        def from_hash(h)
          super
          @active = h[:active] == 0 ? false : true
          @delegation_checked = self.get_datetime h, :delegation_checked
          @delegation_status = h[:delegation_status]
          @master = h[:master]
          @name = h[:name]
          @notified_serial = h[:notified_serial]
          @region_support = h[:region_support] == 0 ? false : true
          @registering = h[:registering]
          @type = h[:type]
        end

        # Add a new DNS Zone
        #
        # @param name [String]
        # @param region_support [Bool]
        # @param register [Bool]
        # @param zone_data [ZoneData]
        # @return [Zone] a new Zone object
        def self.create(name, region_support, register, zone_data)
          param = {}
          param[:name] = name
          param[:region_support] = region_support ? 1 : 0
          param[:register] = register ? 1 : 0
          param[:zone_data] = zone_data.to_hash
          data = Storm::Base::SODServer.remote_call '/Network/DNS/Zone/create',
                                                    param
          z = Zone.new
          z.from_hash data
          z
        end

        # Check if a DNS zone is properly delegated to our nameservers
        #
        # @return [String] result message
        def delegation
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Zone/delegation', :id => self.uniq_id
          data[:delegation]
        end

        # Delete a DNS Zone
        #
        # @return [String] a domain name
        def delete
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Zone/delete', :id => self.uniq_id
          data[:deleted]
        end

        # Get details information on a particular Zone
        def details
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Zone/details', :id => self.uniq_id
          self.from_hash data
        end

        # Get a list of zones
        #
        # @param page_num [Int] page number
        # @param page_size [Int] page size
        # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
        #                :page_size, :page_total and :items (an array of
        #                Zone objects)
        def self.list(page_num, page_size)
          param = {}
          param[:page_num] = page_num if page_num
          param[:page_size] = page_size if page_size
          Storm::Base::SODServer.remote_list '/Network/DNS/Zone/list',
                                             param do |z|
                                              zone = Zone.new
                                              zone.from_hash z
                                              zone
                                            end
        end

        # Update the zone features
        #
        # @param dns_region_support [Bool]
        def update(dns_region_support)
          supp = dns_region_support ? 1 : 0
          data = Storm::Base::SODServer.remote_call '/Network/DNS/Zone/update',
                                                    :DNSRegionSupport => supp,
                                                    :id => self.uniq_id
          self.from_hash data
        end
      end
    end
  end
end
