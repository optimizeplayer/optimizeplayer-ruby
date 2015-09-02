module OptimizePlayer
  module Proxies
    class ProjectProxy < BaseProxy
      def move(attrs)
        client.send_request("projects/move", :post, attrs)
        true
      end

      def entity_name
        'projects'
      end
    end
  end
end
