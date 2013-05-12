require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  class ProductOption < Storm::Base::Model
    attr_accessor :automated
    attr_accessor :display_order
    attr_accessor :display_text
    attr_accessor :key
    attr_accessor :option_key_id
    attr_accessor :public
    attr_accessor :required
    attr_accessor :values

    def from_hash(h)
      super
      @automated = h[:automated] == 0 ? false : true
      @display_order = h[:display_order]
      @display_text = h[:display_text]
      @key = h[:key]
      @option_key_id = h[:option_key_id]
      @public = h[:public] == 0 ? false : true
      @required = h[:required] == 0 ? false : true
      @values = h[:values]
    end
  end

  class ProductPrice < Storm::Base::Model
    attr_accessor :approved
    attr_accessor :balance
    attr_accessor :cc_charge
    attr_accessor :hour
    attr_accessor :initial
    attr_accessor :month
    attr_accessor :next_bill

    def from_hash(h)
      super
      @approved = h[:approved] == 0 ? false : true
      @balance = h[:balance]
      @cc_charge = h[:cc_charge]
      @hour = h[:hour]
      @initial = h[:initial]
      @month = h[:month]
      @next_bill = self.get_date h, :next_bill
    end
  end

  class Product < Storm::Base::Model
    attr_accessor :alias
    attr_accessor :capabilities
    attr_accessor :categories
    attr_accessor :code
    attr_accessor :cycle
    attr_accessor :default_price
    attr_accessor :description
    attr_accessor :features
    attr_accessor :options
    attr_accessor :parent_product
    attr_accessor :prices
    attr_accessor :related_product
    attr_accessor :series

    def from_hash(h)
      super
      @alias = h[:alias]
      @capabilities = h[:capabilities]
      @categories = h[:categories]
      @code = h[:code]
      @cycle = h[:cycle]
      @default_price = h[:default_price]
      @description = h[:description]
      @features = h[:features]
      opt = ProductOption.new
      opt.from_hash h[:options] if h[:options]
      @options = opt
      @parent_product = h[:parent_product]
      @prices = h[:prices]
      @related_product = h[:related_product]
      @series = h[:series]
    end

    # Returns information about a product's pricing and options
    #
    # @param als [String] product alias
    # @param code [String] a valid product info
    def details(als=nil, code=nil)
      raise "at least one of als and code must be provided" if als == nil and \
                                                               code == nil
      param = {}
      param[:alias] = als if als
      param[:code] = code if code
      data = Storm::Base::SODServer.remote_call '/Product/details', param
      self.from_hash data
    end

    # Converts path elements to a product code and alias
    #
    # @param plan [String] a single word
    # @param plan_type [String] a single word
    # @param series [String] a single word
    # @return [Hash] a hash with keys :alias and :code
    def self.get_product_code_from_path(plan, plan_type, series)
      Storm::Base::SODServer.remote_call '/Product/getProductCodeFromPath',
                                         :plan => plan,
                                         :plan_type => plan_type,
                                         :series => series
    end

    # Returns production information for all products, or products in a series
    # or category depending on the arguments passed
    #
    # @param category [String] product category
    # @param page_num [Int] page number
    # @param page_size [Int] page size
    # @param series [String] product series
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Product objects)
    def self.list(category=nil, page_num=0, page_size=0, series=nil)
      param = {}
      param[:category] = category if category
      param[:page_num] = page_num if page_num
      param[:page_size] = page_size if page_size
      param[:series] = series if series
      Storm::Base::SODServer.remote_list '/Product/list', param do |i|
        prd = Product.new
        prd.from_hash i
        prd
      end
    end

    # Get a total price for a product
    #
    # @param code [String] a valid product code
    # @param features [Hash] a hash of features
    # @param region [Int] a region id
    # @return [ProductPrice] a ProductPrice object
    def self.price(code, features, region)
      data = Storm::Base::SODServer.remote_call '/Product/price',
                                                :code => code,
                                                :features => features,
                                                :region => region
      price = ProductPrice.new
      price.from_hash data
      price
    end

    # Returns the minimal price for a product, picking the cheapest feature
    # for each slot
    #
    # @param code [String, Array] one or an array of product codes
    # @return [Array] an array of Hash data, with keys: :product and :price.
    #                 the product value is a string product code, and price
    #                 is also a hash with :hour and :month keys for prices
    def self.starting_price(code)
      Storm::Base::SODServer.remote_call '/Product/startingPrice', :code => code
    end
  end
end
