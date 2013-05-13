require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/Server/server"

module Storm
  module Network
    class Service < Storm::Base::Model
      attr_accessor :dest_port
      attr_accessor :protocol
      attr_accessor :src_port

      def from_hash(h)
        @dest_port = h[:dest_port]
        @protocol = h[:protocol]
        @src_port = h[:src_port]
      end

      def to_hash
        res = {}
        res[:dest_port] = @dest_port
        res[:protocol] = @protocol
        res[:src_port] = @src_port
        res
      end
    end

    class Strategy < Storm::Base::Model
      attr_accessor :description
      attr_accessor :name
      attr_accessor :strategy

      def from_hash(h)
        @description = h[:description]
        @name = h[:name]
        @strategy = h[:strategy]
      end
    end

    class LoadBalancer < Storm::Base::Model
      attr_accessor :capabilities
      attr_accessor :name
      attr_accessor :nodes
      attr_accessor :region
      attr_accessor :services
      attr_accessor :session_persistence
      attr_accessor :ssl_includes
      attr_accessor :ssl_termination
      attr_accessor :strategy
      attr_accessor :vip

      def from_hash(h)
        super
        @capabilities = h[:capabilities]
        @name = h[:name]
        @nodes = h[:nodes].map do |n|
          node = Storm::Server::Server.new
          node.from_hash n
          node
        end
        @region = Storm::Network::ZoneRegion.new
        @region.uniq_id = h[:region_id]
        @services = h[:services].map do |s|
          service = Storm::Network::Service.new
          service.from_hash s
          service
        end
        @session_persistence = h[:session_persistence].to_i == 0 ? false : true
        @ssl_includes = h[:ssl_includes].to_i == 0 ? false : true
        @ssl_termination = h[:ssl_termination].to_i == 0 ? false : true
        @strategy = h[:strategy]
        @vip = h[:vip]
      end

      # Add a single node to an existing loadbalancer
      #
      # @param node [String] a node's IP address
      def add_node(node)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/addNode',
                    :uniq_id => self.uniq_id,
                    :node => node
        self.from_hash data
      end

      # Add a service to an existing loadbalancer
      #
      # @param dest_port [Int] a valid destination port
      # @param src_port [Int] a valid source port
      def add_service(dest_port, src_port)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/addService',
                    :uniq_id => self.uniq_id,
                    :dest_port => dest_port,
                    :src_port => src_port
        self.from_hash data
      end

      # Find out if a loadbalancer name is already in use on an account
      #
      # @param name [String]
      # @return [Bool] whether the name is available
      def self.available(name)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/available', :name => name
        data[:available].to_i == 0 ? false : true
      end

      # Create a new loadbalancer
      #
      # @param name [String] loadbalancer name
      # @param services [Array] an array of service objects
      # @param strategy [String]
      # @param nodes [Array] an array of node IPs
      # @param region [Int] region id
      # @param session_persistence [Bool]
      # @param ssl_cert [String] ssl certificate string
      # @param ssl_includes [Bool]
      # @param ssl_int [String] ssl public certificate string
      # @param ssl_key [String] a private key string
      # @param ssl_termination [Bool]
      # @return [LoadBalancer] a new LoadBalancer object
      def self.create(name, services, strategy, nodes, region,
                      session_persistence, ssl_cert, ssl_includes, ssl_int,
                      ssl_key, ssl_termination)
        param = {}
        param[:name] = name
        param[:services] = services.map { |s| s.to_hash }
        param[:strategy] = strategy
        param[:node] = nodes if nodes
        param[:region] = region if region
        param[:session_persistence] = session_persistence ? 1 : 0
        param[:ssl_cert] = ssl_cert if ssl_cert
        param[:ssl_includes] = ssl_includes ? 1 : 0
        param[:ssl_int] = ssl_int if ssl_int
        param[:ssl_key] = ssl_key if ssl_key
        param[:ssl_termination] = ssl_termination ? 1 : 0
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/create', param
        lb = LoadBalancer.new
        lb.from_hash data
        lb
      end

      # Delete the LoadBalancer
      #
      # @return [String] a result message
      def delete
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/delete', :uniq_id => self.uniq_id
        data[:deleted]
      end

      # Get details information about the current LoadBalancer
      def details
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/details', :uniq_id => self.uniq_id
        self.from_hash data
      end

      # Get a list of all LoadBalancers
      #
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @param region [Int] region id
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                LoadBalancer objects)
      def self.list(page_num, page_size, region)
        param = {}
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        param[:region] = region if region
        Storm::Base::SODServer.remote_list \
                    '/Network/LoadBalancer/list', param do |i|
          lb = LoadBalancer.new
          lb.from_hash i
          lb
        end
      end

      # Gets a list of all possible Loadbalancer Nodes on an account,
      # regardless of whether or not they are currently loadbalanced.
      #
      # @param region [Int] region id
      # @return [Array] an array of Server objects
      def self.possible_nodes(region)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/possibleNodes',
                    :region => region
        data[:items].map { |i|
          server = Storm::Server::Server.new
          server.from_hash i
          server
        }
      end

      # Remove a single node from the current loadbalancer
      #
      # @param node [String] node IP address
      def remove_node(node)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/removeNode',
                    :node => node,
                    :uniq_id => self.uniq_id
        self.from_hash data
      end

      # Remove a single service from the current loadbalancer
      #
      # @param src_port [Int] source port of the service
      def remove_service(src_port)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/removeService',
                    :src_port => src_port,
                    :uniq_id => self.uniq_id
        self.from_hash data
      end

      # Get a list of available strategies
      #
      # @return [Array] an array of Strategy object
      def self.strategies
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/strategies'
        data[:strategies].map { |s|
          strat = Strategy.new
          strat.from_hash s
          strat
        }
      end

      # Update an existing loadbalancer
      #
      # @param name [String] loadbalancer name
      # @param nodes [Array] an array of node IPs
      # @param services [Array] an array of Service object
      # @param session_persistence [Bool]
      # @param ssl_cert [String] a certificate string
      # @param ssl_includes [Bool]
      # @param ssl_int [String] a certificate string
      # @param ssl_key [String] a private key string
      # @param ssl_termination [Bool]
      # @param strategy [String] strategy name
      def update(name, nodes, services, session_persistence, ssl_cert,
                 ssl_includes, ssl_int, ssl_key, ssl_termination,
                 strategy)
        param = {}
        param[:name] = name
        param[:node] = nodes
        param[:services] = services.map { |s| s.to_hash }
        param[:session_persistence] = session_persistence ? 1 : 0
        param[:ssl_cert] = ssl_cert if ssl_cert
        param[:ssl_includes] = ssl_includes ? 1 : 0
        param[:ssl_int] = ssl_int if ssl_int
        param[:ssl_key] = ssl_key if ssl_key
        param[:ssl_termination] = ssl_termination ? 1 : 0
        param[:strategy] = strategy if strategy
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/update', param
        self.from_hash data
      end
    end
  end
end
