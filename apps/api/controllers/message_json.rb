require 'time'
require 'hanami/http/status'

module Api
  module MessageJson
    private def halt_json(code, message = nil, **others)
      halt(code, generate_json({
        code: code,
        message: message || Hanami::Http::Status.message_for(code),
        **others,
      }))
    end

    private def redirect_to_json(url, message = nil, status: 320, **others)
      url = url.to_s
      headers['Location'] = url
      halt_json(status, message, location: url, **others)
    end

    private def generate_json(obj)
      JSON.generate(convert_for_json(obj))
    end

    # Timeの精度は2桁までに統一
    private def convert_for_json(obj)
      case obj
      when Array
        obj.map { |v| convert_for_json(v) }
      when Hash
        obj.transform_values { |v| convert_for_json(v) }
      when Time
        obj.iso8601
      when Hanami::Entity
        convert_for_json(convert_entity(obj))
      else
        obj
      end
    end

    private def convert_entity(entity)
      entity.to_h.except(:id, :created_at, :updated_at)
    end

    private def only_first_errors(errors)
      case errors
      when Hash
        errors.transform_values { |v| only_first_errors(v) }
      when Array
        errors[0, 1]
      else
        errors
      end
    end
  end
end
