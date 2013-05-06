require 'Storm/Base/model'
require 'Storm/Base/sodserver'
require 'Storm/notification'

module Storm
  module Server
    class Server < Storm::Base::Model
      attr_accessor :account
      attr_accessor :active
      attr_accessor :capabilities
      attr_accessor :categories
      attr_accessor :description
      attr_accessor :domain
      attr_accessor :features
      attr_accessor :ip
      attr_accessor :region_id
      attr_accessor :type
      attr_accessor :username
      attr_accessor :valid_source_hvs

      def from_hash(h)
        super
        @account = h[:accnt]
        @active = h[:active]
        @capabilities = h[:capabilities]
        @categories = h[:categories]
        @description = h[:description]
        @domain = h[:domain]
        @features = h[:features]
        @ip = h[:ip]
        @region_id = h[:region_id]
        @type = h[:type]
        @username = h[:username]
        @valid_source_hvs = h[:valid_source_hvs]
      end

      # Checks if a given domain is free.  Will return an adjusted domain
      # name if there was a conflict with another domain on your account.
      #
      # @param domain [String] A fully-qualified domain name
      # @return [String] A fully-qualified domain name
      def self.available(domain)
        data = Storm::Base::SODServer.remote_call '/Server/available',
                                                  :domain => domain
        data[:domain]
      end

      # Clone the current server. Returns the information about the newly
      # created clone.
      #
      # @param password [String] a password of 7-30 characters
      # @param config [Config] an optional Config object
      # @param ip_count [Int] a positive integer
      # @param zone [Int] a positive integer
      # @return [Server] the newly created Server object
      def clone(password, config=nil, ip_count=0, zone=0)
        param = {}
        param[:config_id] = config.uniq_id if config
        param[:ip_count] = ip_count if ip_count
        param[:zone] = zone if zone
        param[:domain] = @domain
        param[:password] = password
        param[:uniq_id] = self.uniq_id
        data = Storm::Base::SODServer.remote_call '/Server/clone', param
        cloned_server = Server.new
        cloned_server.from_hash data
        cloned_server
      end

      # Provision a new server. This fires off the build process, which does
      # the actual provisioning of a new server. 
      #
      # @param backup [Backup] an optional Backup object
      # @param domain [String] a fully-qualified domain name
      # @param features [Hash] an associative array of product features
      # @param image [Image] you can specify a user-created image object
      # @param password [String] the root password for the server (7-30 chars)
      # @param pub_key [String] optional public ssh key you want added
      # @param type [String] the product code for the provisioned server to
      #                      create
      # @param zone [Int] the numerical id for the zone you wish to deploy
      #                   the server in
      # @return [Server] a newly created Server object
      def self.create(domain, features, password, type, backup=nil, image=nil,
                      pub_key=nil, zone=nil)
        param = {}
        param[:domain] = domain
        param[:features] = features
        param[:password] = password
        param[:type] = type
        param[:backup_id] = backup.uniq_id if backup
        param[:image_id] = image.uniq_id if image
        param[:public_ssh_key] = pub_key if pub_key
        param[:zone] = zone if zone

        data = Storm::Base::SODServer.remote_call '/Server/create', param
        server = Server.new
        server.from_hash data
        server
      end

      # Kills a server.  It will refund for any remaining time that has been
      # prepaid, charge any outstanding bandwidth charges, and then start the
      # workflow to tear down the server.
      #
      # @return [String] A six-character identifier
      def destroy
        data = Storm::Base::SODServer.remote_call '/Server/destroy',
                                                  :uniq_id => self.uniq_id
        data[:destroyed]
      end

      # Gets data relevant to a provisioned server
      def details
        data = Storm::Base::SODServer.remote_call '/Server/details',
                                                  :uniq_id => self.uniq_id
        self.from_hash data
      end

      # Get a list of notifications for a specific server
      #
      # @param page_num [Int] a positive number of page number
      # @param page_size [Int] a positive number of page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Notification objects)
      def history(page_num=0, page_size=0)
        raise 'num and size must be positive' unless page_num >= 0 and
                                                     page_size >= 0
        param = {}
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        param[:uniq_id] = self.uniq_id
        data = Storm::Base::SODServer.remote_call '/Server/history', param
        res = {}
        res[:item_count] = data[:item_count]
        res[:item_total] = data[:item_total]
        res[:page_num] = data[:page_num]
        res[:page_size] = data[:page_size]
        res[:page_total] = data[:page_total]
        res[:items] = data[:items].map do |i|
          notification = Notification.new
          notification.from_hash i
          notification
        end
        res
      end

      # Get a list of servers, services, and devices on your account
      #
      # @param category [String] service category, valid options: Dedicated,
      #                          Provisioned, LoadBalancer, HPBS
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @param type [String] a valid subaccnt type descriptor
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Server objects)
      def self.list(category, page_num=0, page_size=0, type='')
        raise 'num and size must be positive' unless page_num >= 0 and
                                                     page_size >= 0
        param = {}
        param[:category] = category
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        param[:type] = type
        data = Storm::Base::SODServer.remote_call '/Server/list', param
        res = {}
        res[:item_count] = data[:item_count]
        res[:item_total] = data[:item_total]
        res[:page_num] = data[:page_num]
        res[:page_size] = data[:page_size]
        res[:page_total] = data[:page_total]
        res[:items] = data[:items].map do |i|
          server = Server.new
          server.from_hash i
          server
        end
        res
      end

      # Reboot the server
      #
      # @param force [Bool] whether forcing a hard reboot of the server
      # @return [Hash] a hash with key :rebooted and :requested, both value
      #                are strings.
      def reboot(force)
        param = {}
        param[:force] = force ? 1 : 0
        param[:uniq_id] = self.uniq_id
        Storm::Base::SODServer.remote_call '/Server/reboot', param
      end

      # Resize the current server to a new configuration
      #
      # @param new_size [Int] the new size
      # @param skip_fs_resize [Bool] whether skip filesystem resizing
      def resize(new_size, skip_fs_resize=false)
        param = {}
        param[:new_size] = new_size
        param[:skip_fs_resize] = skip_fs_resize ? 1 : 0
        param[:uniq_id] = self.uniq_id
        data = Storm::Base::SODServer.remote_call '/Server/resize', param
        self.from_hash data
      end

      # Shutdown the current server
      #
      # @param force [Bool] whether forcing a hard shutdown of the server
      # @return [String] a string identifier
      def shutdown(force)
        param = {}
        param[:force] = force ? 1 : 0
        param[:uniq_id] = self.uniq_id
        data = Storm::Base::SODServer.remote_call '/Server/shutdown', param
        data[:shutdown]
      end

      # Boot the server.  If the server is already running, this will do nothing.
      #
      # @return [String] a string identifier
      def start
        data = Storm::Base::SODServer.remote_call '/Server/start',
                                                  :uniq_id => self.uniq_id
        data[:started]
      end

      # Update the details of the server
      #
      # @param domain [String] a fully-qualified domain name
      # @param features [Hash] a hash of features
      def update(domain, features)
        param = {}
        param[:domain] = domain
        param[:features] = features
        param[:uniq_id] = self.uniq_id
        data = Storm::Base::SODServer.remote_call '/Server/update', param
        self.from_hash data
      end
    end
  end
end