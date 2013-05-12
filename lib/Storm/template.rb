require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class Template < Storm::Base::Model
    attr_accessor :deprecated
    attr_accessor :description
    attr_accessor :manage_level
    attr_accessor :name
    attr_accessor :os
    attr_accessor :zone_availability

    def from_hash(h)
      super
      @deprecated = h[:deprecated] == 0 ? false : true
      @description = h[:description]
      @manage_level = h[:manage_level]
      @name = h[:name]
      @os = h[:os]
      @zone_availability = h[:zone_availability]
    end

    # Get information about a specific template
    #
    # @param template [String] template name
    # @return [Template] a new template object
    def self.details(template)
      data = Storm::Base::SODServer.remote_call '/Storm/Template/details',
                                                :template => template
      tpl = Template.new
      tpl.from_hash data
      tpl
    end

    # Get information about the current template
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Template/details',
                                                :id => self.uniq_id
      self.from_hash data
    end

    # Get a list of useable templates
    #
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Template objects)
    def self.list(page_num=0, page_size=0)
      param = {}
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      Storm::Base::SODServer.remote_list '/Storm/Template/list', param do |i|
        tpl = Template.new
        tpl.from_hash i
        tpl
      end
    end

    # Re-images a server with the template requested
    #
    # @param server [Server] an existing server object
    # @param template [String] template name
    # @param force [Bool] if true it will rebuild the filesystem on the server
    #                     before restoring
    # @return [String] a result message
    def self.restore(server, template, force=false)
      param = {}
      param[:uniq_id] = server.uniq_id
      param[:template] = template
      param[:force] = force ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Template/restore',
                                                param
      data[:reimaged]
    end

    # Re-images a server with the current template
    #
    # @param server [Server] an existing server object
    # @param force [Bool] if true it will rebuild the filesystem on the server
    #                     before restoring
    # @return [String] a result message
    def restore(server, force=false)
      param = {}
      param[:id] = self.uniq_id
      param[:uniq_id] = server.uniq_id
      param[:force] = force ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Template/restore',
                                                param
      data[:reimaged]
    end
  end
end
