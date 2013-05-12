require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Network
    module DNS
      class Domain < Storm::Base::Model
        attr_accessor :admin_handle
        attr_accessor :bill_handle
        attr_accessor :created
        attr_accessor :domain
        attr_accessor :expire
        attr_accessor :ip
        attr_accessor :registrar
        attr_accessor :renewal_max_years
        attr_accessor :renewal_status
        attr_accessor :tech_handle
        attr_accessor :updated

        def from_hash(h)
          @admin_handle = h[:admin_handle]
          @bill_handle = h[:bill_handle]
          @created = self.get_datetime h, :created
          @domain = h[:domain]
          @expire = self.get_datetime h, :expire
          @ip = h[:ip]
          @registrar = h[:registrar]
          @renewal_max_years = h[:renewal_max_years]
          @renewal_status = h[:renewal_status]
          @tech_handle = h[:tech_handle]
          @updated = self.get_datetime h, :updated
        end

        # Returns the list of domain registrations for a given account.
        #
        # @param page_num [Int] page number
        # @param page_size [Int] page size
        # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
        #                :page_size, :page_total and :items (an array of
        #                Domain objects)
        def self.list(page_num, page_size)
          param = {}
          param[:page_num] = page_num if page_num
          param[:page_size] = page_size if page_size
          Storm::Base::SODServer.remote_list \
                '/Network/DNS/Domain/list', param do |i|
                  dm = Domain.new
                  dm.from_hash i
                  dm
                end
        end

        # Renews a domain by insert it into the renewal queue
        #
        # @param domain [String] domain name
        # @param years [Int] renewal time
        # @return [Bool] whether the renewal succeed
        def self.renew(domain, years)
          data = Storm::Base::SODServer.remote_call \
                  '/Network/DNS/Domain/renew',
                  :domain => domain,
                  :years => years
          data[:success]
        end
      end
    end
  end
end
