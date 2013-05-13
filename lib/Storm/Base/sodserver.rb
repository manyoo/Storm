require 'json'
require 'excon'
require 'Storm/Base/exception'

module Storm
  module Base
    STORM_BASE_URL = 'https://api.stormondemand.com'
    STORM_API_VERSION = 'v1'

    class SODServer
      def self.remote_call(path, parameter={})
        real_path = "/#{STORM_API_VERSION}#{path}"
        param = {}
        param[:params] = parameter
        resp = Excon.post STORM_BASE_URL,
                          :path => real_path,
                          :body => param.to_json
        if resp.status == 200
          data = JSON.parse resp.body
          if data[:error_class]
            e_msg = "#{ data[:error_class] } : #{ data[:error_message] }"
            raise Storm::Base::Exception::StormException, e_msg
          else
            data
          end
        else
          e_msg = "HTTP Error: #{ resp.status.to_s } => #{ resp.body }"
          raise Storm::Base::Exception::HttpException, e_msg
        end
      end

      def self.remote_list(path, parameter={})
        real_path = "/#{STORM_API_VERSION}#{path}"
        param = {}
        param[:params] = parameter
        resp = Excon.post STORM_BASE_URL,
                          :path => real_path,
                          :body => param.to_json
        if resp.status == 200
          data = JSON.parse resp.body
          if data[:error_class]
            e_msg = "#{ data[:error_class] } : #{ data[:error_message] }"
            raise Storm::Base::Exception::StormException, e_msg
          else
            res = {}
            res[:items_count] = data[:items_count]
            res[:items_total] = data[:items_total]
            res[:page_num] = data[:page_num]
            res[:page_size] = data[:page_size]
            res[:page_total] = data[:page_total]
            res[:items] = data[:items].map { |e| yield e }
            res
          end
        else
          e_msg = "HTTP Error: #{ resp.status.to_s } => #{ resp.body }"
          raise Storm::Base::Exception::HttpException, e_msg
        end
      end
    end
  end
end
