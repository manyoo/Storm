require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class Backup < Storm::Base::Model
    attr_accessor :account
    attr_accessor :features
    attr_accessor :hv_type
    attr_accessor :name
    attr_accessor :size
    attr_accessor :template
    attr_accessor :time_taken

    def from_hash(h)
      self.uniq_id = h[:id]
      @account = h[:accnt]
      @features = h[:features]
      @hv_type = h[:hv_type]
      @name = h[:name]
      @size = h[:size]
      @template = h[:template]
      @time_taken = self.get_datetime h, :time_taken
    end

    # Get information about a specific backup
    #
    # @param server [Server] an existing server object
    def details(server)
      param = {}
      param[:id] = self.uniq_id
      param[:uniq_id] = server.uniq_id
      data = Storm::Base::SODServer.remote_call '/Storm/Backup/details', param
      self.from_hash data
    end

    # Get a paginated list of backups for a particular server
    #
    # @param server [Server] an existing server object
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Backup objects)
    def self.list(server, page_num=0, page_size=0)
      param = {}
      param[:uniq_id] = server.uniq_id
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      data = Storm::Base::SODServer.remote_call '/Storm/Backup/list', param
      res = {}
      res[:item_count] = data[:item_count]
      res[:item_total] = data[:item_total]
      res[:page_num] = data[:page_num]
      res[:page_size] = data[:page_size]
      res[:page_total] = data[:page_total]
      res[:items] = data[:items].map do |i|
        backup = Backup.new
        backup.from_hash i
        backup
      end
      res
    end

    # Re-images a server with the current backup image
    #
    # @param server [Server] an existing server object
    # @param force [Bool] whether forcing the restore
    # @return [String] a string identifier
    def restore(server, force=false)
      param = {}
      param[:id] = self.uniq_id
      param[:uniq_id] = server.uniq_id
      param[:force] = force ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Backup/restore', param
      data[:restored]
    end
  end
end
