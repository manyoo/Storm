require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Storage
    class Volume < Storm::Base::Model
      attr_accessor :attached_to
      attr_accessor :cross_attach
      attr_accessor :domain
      attr_accessor :label
      attr_accessor :size
      attr_accessor :status
      attr_accessor :zone

      def from_hash(h)
        super
        @attached_to = h[:attached_to]
        @cross_attach = h[:cross_attach] == 0 ? false : true
        @domain = h[:domain]
        @label = h[:label]
        @size = h[:size]
        @status = h[:status]
        @zone = h[:zone]
      end

      # Attach a volume to a particular instance
      #
      # @param server [Server] an server object
      # @return [Hash] a Hash with :attached and :to keys to indicate
      #                the volume and server id
      def attach(server)
        Storm::Base::SODServer.remote_call '/Storage/Block/Volume/attach',
                                           :to => server.uniq_id,
                                           :uniq_id => self.uniq_id
      end

      # Create a new volume
      #
      # @param domain [String] domain name
      # @param size [Int] volume size
      # @param attach [String] a string identifier
      # @param cross_attach [Bool] if enabling cross_attach
      # @param zone [Int] zone id
      # @return [Volume] a new volume object
      def self.create(domain, size, attach, cross_attach, zone)
        param = {}
        param[:domain] = domain
        param[:size] = size
        param[:attach] = attach
        param[:cross_attach] = cross_attach ? 1 : 0
        param[:zone] = zone
        data = Storm::Base::SODServer.remote_call \
                    '/Storage/Block/Volume/create', param
        vol = Volume.new
        vol.from_hash data
        vol
      end

      # Delete a volume, including any and all data stored on it.  The volume
      # must not be attached to any instances to call this method
      #
      # @return [String] a result message
      def delete
        data = Storm::Base::SODServer.remote_call \
                    '/Storage/Block/Volume/delete', :uniq_id => self.uniq_id
        data[:deleted]
      end

      # Detach a volume from an instance
      #
      # @param server [Server] a server object
      # @return [Hash] a hash with keys :detached and :detached_from
      def detach(server=nil)
        param = {}
        param[:uniq_id] = self.uniq_id
        param[:detached_from] = server.uniq_id if server
        Storm::Base::SODServer.remote_call '/Storage/Block/Volume/detach',
                                           param
      end

      # Retrieve information about a specific volume
      def details
        data = Storm::Base::SODServer.remote_call \
                      '/Storage/Block/Volume/details', :uniq_id => self.uniq_id
        self.from_hash data
      end

      # Get a paginated list of block storage volumes for your account
      #
      # @param attached_to [Server] a server object
      # @param page_num [Int] page number
      # @param page_size [Int] page size
      # @return [hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Volume objects)
      def self.list(attached_to=nil, page_num=0, page_size=0)
        param = {}
        param[:attached_to] = attached_to.uniq_id if attached_to
        param[:page_num] = page_num if page_num
        param[:page_size] = page_size if page_size
        Storm::Base::SODServer.remote_list \
                      '/Storage/Block/Volume/list', param do |i|
          vol = Volume.new
          vol.from_hash i
          vol
        end
      end

      # Resize a volume.  Volumes can currently only be resized larger
      #
      # @param size [Int] new size
      # @return [Hash] a hash with keys :old_size, :new_size and :uniq_id
      def resize(size)
        Storm::Base::SODServer.remote_call '/Storage/Block/Volume/resize',
                                           :new_size => size,
                                           :uniq_id => self.uniq_id
      end

      # Update an existing volume.  Currently, only renaming the volume is
      # supported
      #
      # @param domain [String] domain name
      # @param cross_attach [Bool] if enabling croos_attach
      def update(domain, cross_attach)
        param = {}
        param[:uniq_id] = self.uniq_id
        param[:domain] = domain if domain
        param[:cross_attach] = cross_attach ? 1 : 0
        data = Storm::Base::SODServer.remote_call \
                      '/Storage/Block/Volume/update', param
        self.from_hash data
      end
    end
  end
end
