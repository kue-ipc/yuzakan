# frozen_string_literal: true

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

    private def generate_json(obj, assoc: false)
      JSON.generate(convert_for_json(obj, assoc: assoc))
    end

    private def convert_for_json(obj, assoc: false)
      case obj
      when Array
        obj.map { |v| convert_for_json(v, assoc: assoc) }
      when Hash
        obj.transform_values { |v| convert_for_json(v, assoc: assoc) }
      when Time
        # 日時はISO8601形式の文字列にする
        obj.iso8601
      when Hanami::Entity
        convert_for_json(convert_entity(obj, assoc: assoc), assoc: assoc)
      else
        obj
      end
    end

    private def convert_entity(entity, assoc: false)
      data = entity.to_h
        .except(:id, :created_at, :updated_at)
        .reject do |k, v|
          k.end_with?('_id') || v.is_a?(Hanami::Entity) || v.is_a?(Array)
        end
      case entity
      when Attr
        if assoc && entity.mappings
          mappings = entity.mappings.map do |mapping|
            {**convert_entity(mapping), provider: mapping.provider&.name}
          end
          data.merge!({mappings: mappings})
        end
      when Provider
        data.merge!({params: entity.params}) if assoc && entity.params
      when User
        if assoc && entity.members
          data.merge!({
            primary_group: entity.primary_group&.name,
            groups: entity.groups&.map(&:name),
          })
        end
      when Group
        if assoc && entity.members
          data.merge!({
            users: entity.users&.map(&:name),
          })
        end
      when Member
        if assoc
          data.merge!(user: entity.user.name) if entity.user
          data.merge!(user: entity.group.name) if entity.group
        end
      else
        data
      end
      data
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

    # override handle
    def handle_invalid_csrf_token
      Hanami.logger.warn "CSRF attack: expected #{ session[:_csrf_token] }, was #{ params[:_csrf_token] }"
      halt_json 400, errors: [I18n.t('errors.invalid_csrf_token')]
    end
  end
end
