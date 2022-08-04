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
      entity.to_h.except(
        :id,
        :provider_id,
        :attr_id,
        :primary_group_id,
        :created_at, :updated_at)
    end

    private def only_first_errors(errors)
      case errors
      when Hash
        errors.transform_values { |v| only_first_errors(v) }
      when Array
        errors[0, 1]
      when Hanami::Action::Params::Errors
        only_first_errors(errors.to_h)
      else
        errors
      end
    end

    private def merge_errors(errors)
      return errors unless errors.is_a?(Array)

      hash = {}
      list = []
      errors.each do |error|
        if error.is_a?(Hash)
          error = only_first_errors(error)
          hash = hash_deep_merge(hash, only_first_errors(error)) { |_k, s, o| s + o }
        else
          list << error
        end
      end
      list << hash unless hash.empty?
      list
    end

    private def hash_deep_merge(h1, h2, &block)
      h1.merge(h2) do |key, h1_v, h2_v|
        if h1_v.is_a?(Hash) && h2_v.is_a?(Hash)
          hash_deep_merge(h1_v, h2_v, &block)
        elsif block_given?
          block.call(key, h1_v, h2_v)
        else
          h2_v
        end
      end
    end
  end
end
