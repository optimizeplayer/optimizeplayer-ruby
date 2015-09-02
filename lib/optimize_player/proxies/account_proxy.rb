module OptimizePlayer
  module Proxies
    class AccountProxy
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def inspect()
        "#<#{self.class}:0x#{self.object_id.to_s(16)}"
      end

      def fetch
        response = client.send_request(entity_name, :get)
        Converter.convert_to_object(self, response)
      end

      def entity_name
        'account'
      end
    end
  end
end
