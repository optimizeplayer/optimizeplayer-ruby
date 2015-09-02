module OptimizePlayer
  class ApiObject
    @@permanent_attributes = Set.new([:id, :cid, :object, :created_at, :updated_at])

    attr_reader :context

    def initialize(context, attrs={})
      @context = context
      @data = attrs
      @new_data = Set.new
    end

    def inspect()
      id_string = (self.respond_to?(:id) && !self.id.nil?) ? " id=#{self.id}" : ""
      "#<#{self.class}:0x#{self.object_id.to_s(16)}#{id_string}> JSON: " + JSON.pretty_generate(@data)
    end

    def metaclass
      class << self; self; end
    end

    def self.construct_from(context, response)
      api_object = self.new(context, response)
      api_object.refresh

      api_object
    end

    def to_hash
      @data
    end

    def keys
      @data.keys
    end

    def values
      @data.values
    end

    def to_json(*a)
      JSON.generate(@data)
    end

    def as_json(*a)
      @data.as_json(*a)
    end

    def [](k)
      @data[k]
    end

    def []=(k, v)
      send(:"#{k}=", v)
    end

    def refresh
      instance_eval do
        add_accessors(@data.keys)
      end

      @data.each do |k, v|
        @data[k] = Converter.convert_to_object(context, v)
      end

      self
    end

    def refresh_from(data)
      removed = Set.new(@data.keys - data.keys)
      added = Set.new(data.keys - @data.keys)

      instance_eval do
        remove_accessors(removed)
        add_accessors(added)
      end
      removed.each do |k|
        @data.delete(k)
        @new_data.delete(k)
      end
      data.each do |k, v|
        @data[k] = Converter.convert_to_object(context, v)
        @new_data.delete(k)
      end
    end

    def save(opts={})
      attrs = {}
      @new_data.each do |n|
        attrs[n] = @data[n]
      end
      attrs = attrs.merge(opts)

      if attrs.any?
        response = context.client.send_request("#{context.entity_name}/#{id}", :patch, attrs)
        refresh_from(response)
      end
      self
    end

    def delete(opts={})
      response = context.client.send_request("#{context.entity_name}/#{id}", :delete)
      refresh_from(response)
      self
    end
    alias_method :destroy, :delete

    def method_missing(name, *args)
      if name.to_s.end_with?('=')
        attr = name.to_s[0...-1].to_sym
        add_accessors([attr])
        begin
          mth = method(name)
        rescue NameError
          raise NoMethodError.new("Cannot set #{attr} on this object")
        end
        return mth.call(args[0])
      else
        return @data[name.to_s] if @data.has_key?(name.to_s)
      end

      super
    end

    def respond_to_missing?(symbol, include_private = false)
      @data.has_key?(symbol) || super
    end

    def add_accessors(keys)
      metaclass.instance_eval do
        keys.each do |k|
          next if @@permanent_attributes.include?(k.to_sym)
          k_eq = :"#{k}="
          define_method(k) { @data[k] }
          define_method(k_eq) do |v|
            if v == ""
              raise ArgumentError.new(
                "You cannot set #{k} to an empty string." +
                "We interpret empty strings as nil in requests." +
                "You may set #{self}.#{k} = nil to delete the property.")
            end

            @data[k] = v
            @new_data.add(k)
          end
        end
      end
    end

    def remove_accessors(keys)
      metaclass.instance_eval do
        keys.each do |k|
          next if @@permanent_attributes.include?(k.to_sym)
          k_eq = :"#{k}="
          remove_method(k) if method_defined?(k)
          remove_method(k_eq) if method_defined?(k_eq)
        end
      end
    end
  end
end
