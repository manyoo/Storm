require 'date'

module Storm
  module Base
    class Model

      # Build up the object with data in a hash
      #
      # @param h [Hash] the hash data
      def from_hash(h)
      end

      # Get a DateTime object in YYYY-MM-DD HH:MM:SS format from the hash
      #
      # @param h [Hash] the hash data
      # @param name [Symbol] the name of the key
      # @return [DateTime] A DateTime object or nil
      def get_datetime(h, name)
        value = h[name]
        if value
          if self.long_datetime_str? value
            return DateTime.strptime(value, '%Y-%m-%d %H:%M:%S')
          else
            return DateTime.strptime(value, '%Y-%m-%d %H:%M')
          end
        end
        nil
      end

      # Get a Date object in YYYY-MM-DD HH:MM:SS format from the hash
      #
      # @param h [Hash] the hash data
      # @param name [Symbol] the name of the key
      # @return [Date] A Date object or nil
      def get_date(h, name)
        value = h[name]
        if value
          return Date.strptime(value, '%Y-%m-%d')
        end
        nil
      end

      def long_datetime_str?(s)
        idx1 = s.index ':'
        if idx1
          idx2 = s[(idx1+1)..-1].index ':'
          if idx2
            return true
          end
        end
        false
      end
    end
  end
end