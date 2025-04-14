# auto_register: false
# frozen_string_literal: true

# TODO: 使わない？

module API
  module Views
    module Helpers
      module JsonHelper
        def generate_json(obj, assoc: false)
          JSON.generate(convert_for_json(obj, assoc: assoc))
        end

        def convert_for_json(obj, assoc: false)
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

        def convert_struct(struct, assoc: false)
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
      end
    end
  end
end
