module OptimizePlayer
  module Errors
    class OptimizePlayerError < StandardError
      attr_reader :status
      attr_reader :error
      attr_reader :message

      def initialize(status=nil, error=nil, message=nil)
        @status = status
        @error = error
        @message = message
      end

      def to_s
        status_string = status.nil? ? "" : "(Status #{status})"
        "#{status_string} #{error} - #{message}"
      end
    end
  end
end
