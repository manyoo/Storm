require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class Image < Storm::Base::Model
    attr_accessor :account
    attr_accessor :features
    attr_accessor :hv_type
    attr_accessor :name
    attr_accessor :size
    attr_accessor :source_hostname
    attr_accessor :source_uniq_id
    attr_accessor :template
    attr_accessor :template_description
    attr_accessor :time_taken

    def from_hash(h)
      self.uniq_id = h[:id]
      @account = h[:accnt]
      @features = h[:features]
      @hv_type = h[:hv_type]
      @name = h[:name]
      @size = h[:size]
      @source_hostname = h[:source_hostname]
      @source_uniq_id = h[:source_uniq_id]
      @template = h[:template]
      @template_description = h[:template_description]
      @time_taken = self.get_datetime h, :time_taken
    end

    # Fires off a process to image the server right now
    #
    # @param name [String] a name for the image
    # @param server [Server] an existing server object
    # @return [String] a string permitting tabs, carriage returns and newlines
    def self.create(name, server)
      data = Storm::Base::SODServer.remote_call '/Storm/Image/create',
                                                :name => name,
                                                :uniq_id => server.uniq_id
      data[:created]
    end

    # Fires off a process to delete the requested image from the image server
    # that stores it
    #
    # @return [Int] a positive integer value
    def delete
      data = Storm::Base::SODServer.remote_call '/Storm/Image/delete',
                                                :id => self.uniq_id
      data[:deleted]
    end

    # Get information about a specific image
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Image/details',
                                                :id => self.uniq_id
      self.from_hash data
    end

    # Get a paginated list of previously-created images for your account
    #
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Image objects)
    def self.list(page_num=0, page_size=0)
      param = {}
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      data = Storm::Base::SODServer.remote_call '/Storm/Image/list', param
      res = {}
      res[:item_count] = data[:item_count]
      res[:item_total] = data[:item_total]
      res[:page_num] = data[:page_num]
      res[:page_size] = data[:page_size]
      res[:page_total] = data[:page_total]
      res[:items] = res[:items].map do |i|
        img = Image.new
        img.from_hash i
        img
      end
      res
    end

    # Re-images a server with the image requested
    #
    # @param server [Server] an existing server object
    # @param force [Bool] whether forcing the restore
    # @return [String] a string message
    def restore(server, force=false)
      param = {}
      param[:id] = self.uniq_id
      param[:uniq_id] = server.uniq_id
      param[:force] = force ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Image/restore', param
      data[:reimaged]
    end

    # Update an existing image.  Currently, only renaming the image is
    # supported.
    #
    # @param name [String] the new image name
    def update(name)
      data = Storm::Base::SODServer.remote_call '/Storm/Image/restore',
                                                :id => self.uniq_id,
                                                :name => name
      self.from_hash data
    end
  end
end
