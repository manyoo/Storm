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
      @resolved = h[:resolved] == 0 ? false : true
      @severity = h[:severity]
      @startdate = self.get_datetime h, :startdate
      @system = h[:system]
      @system_identifier = h[:system_identifier]
    end

    # Get a list of all notifications for an account or server
    #
    # @param category [String] category name
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @param resolved [Bool] if the Notification is resolved
    # @param system [String] system name
    # @param server [Server] a server object
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Notification objects)
    def self.all(category=nil, page_num=0, page_size=0, resolved=false,
                 system=nil, server=nil)
      param = {}
      param[:category] = category if category
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      param[:resolved] = resolved ? 1 : 0
      param[:system] = system if system
      param[:uniq_id] = server.uniq_id if server
      data = Storm::Base::SODServer.remote_call '/Notifications/all', param
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

    # Get a list of unresolved notifcations for an account or server
    #
    # @param category [String] category name
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @param resolved [Bool] if the Notification is resolved
    # @param system [String] system name
    # @param server [Server] a server object
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Notification objects)
    def self.current(category=nil, page_num=0, page_size=0, resolved=false,
                     system=nil, server=nil)
      param = {}
      param[:category] = category if category
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      param[:resolved] = resolved ? 1 : 0
      param[:system] = system if system
      param[:uniq_id] = server.uniq_id if server
      data = Storm::Base::SODServer.remote_call '/Notifications/current', param
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

    # Gets information about a specific notification
    #
    # @param system [String] system name
    # @param system_identifier [String] system identifier
    # @param limit [Int] a non-negitive integer
    # @return [Notification] a new Notification object
    def self.details(system, system_identifier, limit=0)
      param = {}
      param[:limit] = limit if limit
      param[:system] = system
      param[:system_identifier] = system_identifier
      data = Storm::Base::SODServer.remote_call '/Notifications/details', param
      notification = Notification.new
      notification.from_hash data
      notification
    end

    # Gets information about the current notification
    def details
      data = Storm::Base::SODServer.remote_call '/Notifications/details',
                                                :id => self.uniq_id
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
