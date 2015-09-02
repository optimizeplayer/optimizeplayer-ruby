module OptimizePlayer
  class Account < ApiObject
    def save(opts={})
      attrs = {}
      @new_data.each do |n|
        attrs[n] = @data[n]
      end
      attrs = attrs.merge(opts)

      if attrs.any?
        response = context.client.send_request(context.entity_name, :patch, attrs)
        refresh_from(response)
      end
      self
    end

    def delete(opts={})
      response = context.client.send_request(context.entity_name, :delete)
      refresh_from(response)
      self
    end
    alias_method :destroy, :delete
  end
end
