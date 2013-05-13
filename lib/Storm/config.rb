require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class Config < Storm::Base::Model
    attr_accessor :active
    attr_accessor :available
    attr_accessor :category
    attr_accessor :cpu_cores
    attr_accessor :cpu_count
    attr_accessor :cpu_hyperthreading
    attr_accessor :cpu_model
    attr_accessor :cpu_speed
    attr_accessor :description
    attr_accessor :disk
    attr_accessor :disk_count
    attr_accessor :disk_total
    attr_accessor :disk_type
    attr_accessor :featured
    attr_accessor :memory
    attr_accessor :raid_level
    attr_accessor :ram_available
    attr_accessor :ram_total
    attr_accessor :vcpu
    attr_accessor :zone_availability

    def from_hash(h)
      super
      @active = h[:active].to_i == 1 ? true : false
      @available = h[:available]
      @category = h[:category]
      @cpu_cores = h[:cpu_cores]
      @cpu_count = h[:cpu_count]
      @cpu_hyperthreading = h[:cpu_hyperthreading].to_i == 1 ? true : false
      @cpu_model = h[:cpu_model]
      @cpu_speed = h[:cpu_speed]
      @description = h[:description]
      @disk = h[:disk]
      @disk_count = h[:disk_count]
      @disk_total = h[:disk_total]
      @disk_type = h[:disk_type]
      @featured = h[:featured].to_i == 1 ? true : false
      @raid_level = h[:raid_level]
      @ram_available = h[:ram_available]
      @ram_total = h[:ram_total]
      @vcpu = h[:vcpu]
      @zone_availability = h[:zone_availability]
    end

    # Get information about a specific config
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Config/details',
                                                :id => self.uniq_id
      self.from_hash data
    end

    # Get a list of available server configurations
    #
    # @param available [Bool] if the config is available
    # @param category [String] config category ('storm' by default)
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Config objects)
    def self.list(available, category='storm', page_num=0, page_size=0)
      param = {}
      param[:available] = available ? 1 : 0
      param[:category] = category
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      Storm::Base::SODServer.remote_list '/Storm/Config/list', param do |i|
        conf = Config.new
        conf.from_hash i
        conf
      end
    end
  end
end
