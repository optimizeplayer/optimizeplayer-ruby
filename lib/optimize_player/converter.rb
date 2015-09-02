module OptimizePlayer
  module Converter
    def self.convert_to_object(context, response)
      case response
      when Array
        response.map { |r| convert_to_object(context, r) }
      when Hash
        obj_klass = response['object_class']
        klass = Object.const_get("OptimizePlayer::#{obj_klass}")
        klass.construct_from(context, response)
      else
        response
      end
    end
  end
end
