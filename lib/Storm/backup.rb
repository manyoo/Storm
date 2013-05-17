require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  # This class defines API methods for managing backups.
  class Backup < Storm::Base::Model
    attr_accessor :account
    attr_accessor :features
    attr_accessor :hv_type
    attr_accessor :id
    attr_accessor :name
    attr_accessor :size
    attr_accessor :template
    attr_accessor :time_taken
    attr_accessor :uniq_id

    def from_hash(h)
      @account = h[:accnt]
      @features = h[:features]
      @hv_type = h[:hv_type]
      @id = h[:id]
      @name = h[:name]
      @size = h[:size]
      @template = h[:template]
      @time_taken = self.get_datetime h, :time_taken
      @uniq_id = h[:uniq_id]
    end

    # Get information about a specific backup
    #
    # @param options [Hash] optional keys:
    #  :server [Server] an existing server object
    def details(options={})
      param = { :id => @id }.merge options
      if param[:server]
        param[:uniq_id] = param[:server].uniq_id
        param.delete :server
      end
      data = Storm::Base::SODServer.remote_call '/Storm/Backup/details', param
      self.from_hash data
    end

    # Get a paginated list of backups for a particular server
    #
    # @param options [Hash] optional keys:
    #  :server [Server] an existing server object,
    #  :page_num [Int] page number,
    #  :page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Backup objects)
    def self.list(options={})
      if options[:server]
        options[:uniq_id] = options[:server].uniq_id
        options.delete :server
      end
      Storm::Base::SODServer.remote_list '/Storm/Backup/list', options do |i|
        backup = Backup.new
        backup.from_hash i
        backup
      end
    end

    # Re-images a server with the current backup image
    #
    # @param server [Server] an existing server object
    # @param options [Hash] optional keys:
    #  :force [Bool] whether forcing the restore
    # @return [String] a string identifier
    def restore(server, options={})
      param = {
        :id => @id,
        :uniq_id => server.uniq_id
        }.merge options
      param[:force] = param[:force] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Backup/restore', param
      data[:restored]
    end
  end
end
