require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class Alert < Storm::Base::Model
    attr_accessor :alertdate
    attr_accessor :description

    def from_hash(h)
      @alertdate = self.get_datetime h, :alertdate
      @description = h[:description]
    end
  end

  class Notification < Storm::Base::Model
    attr_accessor :alerts
    attr_accessor :category
    attr_accessor :description
    attr_accessor :enddate
    attr_accessor :last_alert
    attr_accessor :modifieddate
    attr_accessor :resolved
    attr_accessor :severity
    attr_accessor :startdate
    attr_accessor :system
    attr_accessor :system_identifier

    def from_hash(h)
      self.uniq_id = h[:id]
      if h[:alerts]
        @alerts = h[:alerts].map do |a|
          alert = Alert.new
          alert.from_hash a
          alert
        end
      end
      @category = h[:category]
      @description = h[:description]
      @enddate = self.get_datetime h, :enddate
      @last_alert = h[:last_alert]
      @modifieddate = self.get_datetime h, :modifieddate
      @resolved = h[:resolved].to_i == 0 ? false : true
      @severity = h[:severity]
      @startdate = self.get_datetime h, :startdate
      @system = h[:system]
      @system_identifier = h[:system_identifier]
    end

    # Get a list of all notifications for an account or server
    #
    # @param options [Hash] optional keys:
    #  :category [String] category name
    #  :page_num [Int] page number
    #  :page_size [Int] page size
    #  :resolved [Bool] if the Notification is resolved
    #  :system [String] system name
    #  :server [Server] a server object
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Notification objects)
    def self.all(options={})
      options[:resolved] = options[:resolved] ? 1 : 0
      if options[:server]
        options[:uniq_id] = options[:server].uniq_id
        options.delete :server
      end
      Storm::Base::SODServer.remote_list '/Notifications/all', options do |i|
        notification = Notification.new
        notification.from_hash i
        notification
      end
    end

    # Get a list of unresolved notifcations for an account or server
    #
    # @param options [Hash] optional keys:
    #  :category [String] category name
    #  :page_num [Int] page number
    #  :page_size [Int] page size
    #  :resolved [Bool] if the Notification is resolved
    #  :system [String] system name
    #  :server [Server] a server object
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Notification objects)
    def self.current(options={})
      options[:resolved] = options[:resolved] ? 1 : 0
      if options[:server]
        options[:uniq_id] = options[:server].uniq_id
        options.delete :server
      end
      Storm::Base::SODServer.remote_list '/Notifications/current', options do |i|
        notification = Notification.new
        notification.from_hash i
        notification
      end
    end

    # Gets information about a specific notification
    #
    # @param options [Hash] optional keys:
    #  :system [String] system name
    #  :system_identifier [String] system identifier
    #  :limit [Int] a non-negitive integer
    # @return [Notification] a new Notification object
    def self.details(options={})
      data = Storm::Base::SODServer.remote_call \
                  '/Notifications/details', options
      notification = Notification.new
      notification.from_hash data
      notification
    end

    # Gets information about the current notification
    #
    # @param options [Hash] optional keys:
    #  :limit [Int]
    def details(options={})
      param = { :id => self.uniq_id }.merge options
      data = Storm::Base::SODServer.remote_call '/Notifications/details',
                                                param
      self.from_hash data
    end

    # Resolve an existing open notification
    #
    # @param system [String] system name
    # @param system_identifier [String] system identifier
    # @return [Notification] a new notification object
    def self.resolve(system, system_identifier)
      data = Storm::Base::SODServer.remote_call '/Notifications/resolve',
                                :system => system,
                                :system_identifier => system_identifier
      notification = Notification.new
      notification.from_hash data
      notifcations
    end

    # Resolve the current notification
    def resolve
      data = Storm::Base::SODServer.remote_call '/Notifications/resolve',
                                                :id => self.uniq_id
      self.from_hash data
    end
  end
end
