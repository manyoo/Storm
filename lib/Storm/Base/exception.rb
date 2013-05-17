module Storm
  module Base
    # This module defines the basic exception types used
    module Exception
      # Exception type for all Storm exceptions/errors we get from the API server
      class StormException < StandardError
      end

      # Exception type for all HTTP level errors
      class HttpException < StandardError
      end
    end
  end
end