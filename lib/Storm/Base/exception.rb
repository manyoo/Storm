module Storm
  module Base
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