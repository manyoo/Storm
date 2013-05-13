require 'json'
require 'base64'
require 'excon'
require 'Storm/Base/exception'
require 'Storm/Account/auth'

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
                          :body => param.to_json,
                          :headers => self.build_auth_header
        if resp.status == 200
          data = JSON.parse resp.body, :symbolize_names => true
          if data[:error_class]
            e_msg = "#{ data[:error_class] } : #{ data[:full_message] }"
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
                          :body => param.to_json,
                          :headers => self.build_auth_header
        if resp.status == 200
          data = JSON.parse resp.body, :symbolize_names => true
          if data[:error_class]
            e_msg = "#{ data[:error_class] } : #{ data[:full_message] }"
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

      def self.build_auth_header
        username = Storm::Account::Auth.username
        password = Storm::Account::Auth.password
        token = Storm::Account::Auth.token_string
        if username == nil and password == nil
          raise Storm::Base::Exception::StormException,
                'Please setup your username and password first.'
        end
        credential = token ? token : password
        str = Base64.encode64("#{ username }:#{ credential }").chomp
        {'Content-Type' => 'application/json',
         'Authorization' => "Basic #{ str }"
        }
      end
    end
  end
end
