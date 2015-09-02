module OptimizePlayer
  module Proxies
    class BaseProxy
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def inspect()
        "#<#{self.class}:0x#{self.object_id.to_s(16)}"
      end

      def all(attrs={})
        response = client.send_request(entity_name, :get, attrs)
        Converter.convert_to_object(self, response)
      end

      def find(id)
        response = client.send_request("#{entity_name}/#{id}", :get)
        Converter.convert_to_object(self, response)
      end

      def create(attrs)
        response = client.send_request(entity_name, :post, attrs)
        Converter.convert_to_object(self, response)
      end

      protected

        def entity_name
          raise NotImplementedError.new('You should implement actions on its subclasses')
        end
    end
  end
end
