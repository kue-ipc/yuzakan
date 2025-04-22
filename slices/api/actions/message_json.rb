# frozen_string_literal: true

require "time"
require "hanami/http/status"

module API
  module Actions
    module MessageJSON
      private def halt_json(request, response, status, location: nil, **others)
        location ||= request.path
        halt(status, {
          status: {
            code: status,
            message: Hanami::Http::Status.message_for(status),
          },
          location:,
          flash: response.flash.sweep.map { |k, v| [k, v] }.to_h, # rubocop: disable Style/MapToHash
          **others,
        }.to_json)
      end

      private def redirect_to_json(request, response, url, status: 302,
        **others)
        response.location = url
        halt_json(request, response, status, location: url, **others)
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
        when Yuzakan::DB::Struct
          convert_for_json(convert_struct(obj, assoc: assoc), assoc: assoc)
        else
          obj
        end
      end

      private def convert_struct(struct, assoc: false)
        data = struct.to_h
          .except(:id, :created_at, :updated_at)
          .reject { |k, v|
            k.end_with?("_id") || v.is_a?(Yuzakan::DB::Struct) || v.is_a?(Array)
          }
        case struct
        when Yuzakan::Structs::Attr
          if assoc && struct.mappings
            mappings = struct.mappings.map { |mapping|
              {**convert_struct(mapping), provider: mapping.provider&.name}
            }
            data.merge!({mappings: mappings})
          end
        when Yuzakan::Structs::Provider
          data.merge!({params: struct.params}) if assoc && struct.params
        when User
          if assoc && struct.members
            data.merge!({
              primary_group: struct.primary_group&.name,
              groups: struct.groups&.map(&:name),
            })
          end
        when Yuzakan::Structs::Group
          if assoc && struct.members
            data.merge!({
              users: struct.users&.map(&:name),
            })
          end
        when Yuzakan::Structs::Member
          if assoc
            data.merge!(user: struct.user.name) if struct.user
            data.merge!(user: struct.group.name) if struct.group
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
            hash = hash_deep_merge(hash, only_first_errors(error)) { |_k, s, o|
              s + o
            }
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

      private def call_interacttor(interactor, params)
        result = interactor.call(params)
        halt_json(500, errors: result.errors) if result.failure?

        result
      end
    end
  end
end
