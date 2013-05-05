require 'json'
require 'excon'

module Storm
  module Base
    STORM_BASE_URL = 'https://api.stormondemand.com'
    STORM_API_VERSION = 'v1'

    class SODServer
      def self.remote_call(path, paramter={})
        real_path = "/#{STORM_API_VERSION}#{path}"
        resp = Excon.post :path => real_path, :body => paramter.to_json
        if resp.status == 200
          resp_data = JSON.parse resp.body
          # TODO: Check response exception here.
        else
          # TODO: Raise customized Exception here.
        end
      end
    end
  end
end
