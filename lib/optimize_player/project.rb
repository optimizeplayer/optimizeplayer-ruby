module OptimizePlayer
  class Project < ApiObject
    def inspect()
      cid_string = (self.respond_to?(:cid) && !self.cid.nil?) ? " cid=#{self.cid}" : ""
      "#<#{self.class}:0x#{self.object_id.to_s(16)}#{cid_string}> JSON: " + JSON.pretty_generate(@data)
    end

    def id
      cid
    end

    def set_position(position)
      response = context.client.send_request("projects/#{id}/set_position", :put, position: position)
      refresh_from(response)
      self
    end

    def toggle_favorite
      response = context.client.send_request("projects/#{id}/toggle_favorite", :put)
      refresh_from(response)
      self
    end
  end
end
