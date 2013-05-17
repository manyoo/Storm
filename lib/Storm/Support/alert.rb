require "Storm/Base/sodserver"

module Storm
  module Support
    # This module is an interface to support alerts.
    module Alert
      # Get the details of the active support alert
      #
      # @return [Hash] a hash with keys: :subject and :message with string values
      def self.get_active
        data = Storm::Base::SODServer.remote_call '/Support/Alert/getActive'
        data[:active_alert]
      end
    end
  end
end