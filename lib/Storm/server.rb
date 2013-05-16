require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/config"

module Storm
  class ServerZone < Storm::Base::Model
    attr_accessor :name
    attr_accessor :region

    def from_hash(h)
      super
      @name = h[:name]
      @region = ServerRegion.new
      @region.from_hash h[:region]
    end
  end

  class ServerRegion < Storm::Base::Model
    attr_accessor :name

    def from_hash(h)
      super
      @name = h[:name]
    end
  end

  class Status < Storm::Base::Model
    attr_accessor :detailed_status
    attr_accessor :progress
    attr_accessor :running
    attr_accessor :status

    def from_hash(h)
      @detailed_status = h[:detailed_status]
      @progress = h[:progress]
      if h[:running]
        @running = h[:running].map { |s|
          rs = RunStatus.new
          rs.from_hash s
          rs
        }
      end
      @status = h[:status]
    end
  end

  class RunStatus < Storm::Base::Model
    attr_accessor :current_step
    attr_accessor :detailed_status
    attr_accessor :name
    attr_accessor :status

    def from_hash(h)
      @current_step = h[:current_step]
      @detailed_status = h[:detailed_status]
      @name = h[:name]
      @status = h[:status]
    end
  end

  class Server < Storm::Base::Model
    attr_accessor :account
    attr_accessor :active
    attr_accessor :backup_enabled
    attr_accessor :backup_plan
    attr_accessor :backup_quota
    attr_accessor :backup_size
    attr_accessor :bandwidth_quota
    attr_accessor :config_description
    attr_accessor :config
    attr_accessor :create_date
    attr_accessor :domain
    attr_accessor :ip
    attr_accessor :ip_count
    attr_accessor :manage_level
    attr_accessor :template
    attr_accessor :template_description
    attr_accessor :type
    attr_accessor :zone

    def from_hash(h)
      super
      @account = h[:accnt]
      @active = h[:active].to_i == 1 ? true : false
      @backup_enabled = h[:backup_enabled].to_i == 1 ? true : false
      @backup_plan = h[:backup_plan]
      @backup_quota = h[:backup_quota]
      @backup_size = h[:backup_size]
      @bandwidth_quota = h[:bandwidth_quota]
      @config_description = h[:config_description]
      @config = Storm::Config.new
      @config.uniq_id = h[:config_id]
      @create_date = self.get_datetime h, :create_date
      @domain = h[:domain]
      @ip = h[:ip]
      @ip_count = h[:ip_count]
      @manage_level = h[:manage_level]
      @template = h[:template]
      @template_description = h[:template_description]
      @type = h[:type]
      @zone = ServerZone.new
      @zone.from_hash h[:zone]
    end

    # Clone a server
    #
    # @param domain [String] domain name
    # @param password [String]
    # @param options [Hash] optional keys:
    #   :config [Config] a config object,
    #   :ip_count [Int],
    #   :zone [ServerZone]
    # @return [Server] a new Server object
    def clone(domain, password, options={})
      param = {
        :domain => domain,
        :password => password,
        :uniq_id => self.uniq_id
      }.merge options
      if param[:config]
        param[:config_id] = param[:config].uniq_id
        param.delete :config
      end
      param[:zone] = param[:zone].uniq_id if param[:zone]
      data = Storm::Base::SODServer.remote_call '/Storm/Server/clone', param
      server = Server.new
      server.from_hash data
      server
    end

    # Provision a new server
    #
    # @param config [Config]
    # @param domain [String]
    # @param password [String]
    # @param options [Hash] optional keys:
    # :antivirus [String],
    # :backup_enabled [Bool],
    # :backup [Backup] a Backup object,
    # :backup_plan [String],
    # :backup_quota [Int],
    # :backup_size [Float],
    # :bandwidth_quota [Int],
    # :image [Image] an Image object,
    # :ip_count [Int],
    # :ms_sql [String],
    # :public_ssh_key [String],
    # :template [Template] a Template object
    # :zone [ServerZone] a ServerZone object
    # @return [Server] a new Server object
    def self.create(config, domain, password, options={})
      param = {
        :config_id => config.uniq_id,
        :domain => domain,
        :password => password
      }.merge options
      param[:backup_enabled] = param[:backup_enabled] ? 1 : 0
      if param[:backup]
        param[:backup_id] = param[:backup].uniq_id
        param.delete :backup
      end
      if param[:image]
        param[:image_id] = param[:image].uniq_id
        param.delete :image
      end
      param[:template] = param[:template].name if param[:template]
      param[:zone] = param[:zone].uniq_id if param[:zone]
      data = Storm::Base::SODServer.remote_call '/Storm/Server/create', param
      server = Server.new
      server.from_hash data
      server
    end

    # Destroy a server
    #
    # @return [String] a result message
    def destroy
      data = Storm::Base::SODServer.remote_call '/Storm/Server/destroy',
                                                :uniq_id => self.uniq_id
      data[:destroyed]
    end

    # Get details information for the server
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Server/details',
                                                :uniq_id => self.uniq_id
      self.from_hash data
    end

    # Get a list of notifications for a specific server
    #
    # @param options [Hash] optional keys:
    #  :page_num [Int] a positive number of page number
    #  :page_size [Int] a positive number of page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Notification objects)
    def history(options={})
      param = { :uniq_id => self.uniq_id }.merge options
      Storm::Base::SODServer.remote_list '/Storm/Server/history', param do |i|
        notification = Notification.new
        notification.from_hash i
        notification
      end
    end

    # Get a list of servers, services, and devices on your account
    #
    # @param options [Hash] optional keys:
    #  :page_num [Int] page number
    #  :page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Server objects)
    def self.list(options={})
      Storm::Base::SODServer.remote_list '/Storm/Server/list', options do |i|
        server = Server.new
        server.from_hash i
        server
      end
    end

    # Reboot the server
    #
    # @param options [Hash] optional keys:
    #  :force [Bool] whether forcing a hard reboot of the server
    # @return [String] a result message
    def reboot(options={})
      param = { :uniq_id => self.uniq_id }.merge options
      param[:force] = param[:force] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Server/reboot', param
      data[:rebooted]
    end

    # Resize the current server to a new configuration
    #
    # @param config [Config] a Config object
    # @param options [Hash] optional keys:
    #  :skip_fs_resize [Bool] whether skip filesystem resizing
    def resize(config, new_size, options={})
      param = {
        :config_id => config.uniq_id,
        :uniq_id => self.uniq_id
        }.merge options
      options[:skip_fs_resize] = options[:skip_fs_resize] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Server/resize', param
      self.from_hash data
    end

    # Shutdown the current server
    #
    # @param options [Hash] optional keys:
    #  :force [Bool] whether forcing a hard shutdown of the server
    # @return [String] a string identifier
    def shutdown(options={})
      param = { :uniq_id => self.uniq_id }.merge options
      param[:force] = param[:force] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Server/shutdown', param
      data[:shutdown]
    end

    # Boot the server.  If the server is already running, this will do nothing.
    #
    # @return [String] a string identifier
    def start
      data = Storm::Base::SODServer.remote_call '/Storm/Server/start',
                                                :uniq_id => self.uniq_id
      data[:started]
    end

    # Get the current status of a server
    #
    # @return [Status] a Status object
    def status
      data = Storm::Base::SODServer.remote_call '/Storm/Server/status',
                                                :uniq_id => self.uniq_id
      st = Status.new
      st.from_hash data
      st
    end

    # Update the details of the server
    #
    # @param options [Hash] optional keys:
    #  :backup_enabled [Bool],
    #  :backup_plan [String],
    #  :backup_quota [Int],
    #  :bandwidth_quota [Int],
    #  :domain [String] a fully-qualified domain name
    def update(options={})
      param = { :uniq_id => self.uniq_id }.merge options
      param[:backup_enabled] = param[:backup_enabled] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Server/update', param
      self.from_hash data
    end
  end
end