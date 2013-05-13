require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Monitoring
    class Service < Storm::Base::Model
      attr_accessor :can_monitor
      attr_accessor :enabled
      attr_accessor :services
      attr_accessor :unmonitored

      def from_hash(h)
        super
        @can_monitor = h[:can_monitor]
        @enabled = h[:enabled].to_i == 1 ? true : false
        @services = h[:services]
        @unmonitored = h[:unmonitored].to_i == 1 ? true : false
      end

      # Get the current monitoring settings for a server
      #
      # @param server [Server] the specified server
      # @return [Service] a Service object
      def self.get(server)
        data = Storm::Base::SODServer.remote_call '/Monitoring/Services/get',
                                                  :uniq_id => server.uniq_id
        serv = Service.new
        serv.from_hash data
        serv
      end

      # Get a list of IPs that our monitoring system runs from
      #
      # @return [Array] an array of IPs
      def self.monitoring_IPs
        Storm::Base::SODServer.remote_call '/Monitoring/Services/monitoringIps'
      end

      # Get the current service status for each monitored service on a server
      #
      # @param server [Server] the specified server
      # @return [Hash] a hash of service status
      def self.status(server)
        Storm::Base::SODServer.remote_call '/Monitoring/Services/status',
                                           :uniq_id => server.uniq_id
      end

      # Update service monitoring settings for a server
      #
      # @param server [Server] the specified server
      # @param enabled [Bool] if it's enabled
      # @param services [Array] an array of strings
      # @return [Service] a new Service object
      def self.update(server, enabled, services)
        param = {}
        param[:uniq_id] = server.uniq_id
        param[:enabled] = enabled ? 1 : 0
        param[:services] = services
        data = Storm::Base::SODServer.remote_call \
                     '/Monitoring/Services/update', param
        serv = Service.new
        serv.from_hash data
        serv
      end
    end
  end
end
