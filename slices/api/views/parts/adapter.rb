# auto_register: false
# frozen_string_literal: true

require "hanami/utils/json"

module API
  module Views
    module Parts
      class Adapter < API::Views::Part
        def to_h(restricted: false, simplified: false)
          label = context.t("adapters.#{value.name}.label", default: value.name)
          case [restricted, simplified]
          in [true, _] | [_, true]
            {
              name: value.name,
              label:,
            }
          in [false, false]
            {
              name: value.name,
              label:,
              group: value.class.has_group?,
              primary: value.class.has_primary_group?,
              params: {
                schema: value.class.schema,
                defaults: value.class.default_params,
              },
            }
          end
        end

        def to_json(...)
          hash = to_h(...)
          if hash[:params]
            schema = hash[:params][:schema]
            defaults = hash[:params][:defaults]
            i18n_scope = "adapters.#{value.name}.params"
            hash = {**hash, params: json_schema(schema, defaults:, i18n_scope:)}
          end
          helpers.params_to_json(hash)
        end

        def json_schema(schema, defaults: {}, i18n_scope: "")
          schema.ast => [:set, rules]
          rules.to_h do |rule|
            item_required =
              case rule
              in [:and, item]
                true
              in [:implication, item]
                false
              end
            item => [[:predicate, [:key?, [[:name, name], [:input, _undefined]]]], [:key, [_name, Array => ast]]]
            property = ast_to_property(ast, name, defaults:, i18n_scope:)
            property[:required] = true if item_required
            [name, property]
          end
        end

        private def ast_to_property(ast, name, defaults: {}, i18n_scope: "")
          {
            title: context.t("#{name}.label", scope: i18n_scope, default: nil),
            description: context.t("#{name}.description", scope: i18n_scope, default: nil),
            default: defaults[name],
            **parse_ast(ast, name),
          }.compact
        end

        private def parse_ast(ast, name)
          case ast
          in [:predicate, predicate]
            convert_predicate(predicate, name)
          in [:and, Array => nested_asts]
            # NOTE: notはexcluded_from?の場合のみなのでdeep_mergeは今のところ不要。
            # FIXME: string型以外はsize関係については間違ったプロパティになっている。
            {}.merge(*nested_asts.map { |nested_ast| parse_ast(nested_ast, name) })
          in [:implication, [:not, [:predicate, [:nil?, [[:input, _undefined]]]]], nested_ast]
            {**parse_ast(nested_ast, name), maybe: true}
          end
        end

        private def convert_predicate(predicate, _name)
          # https://dry-rb.org/gems/dry-schema/main/basics/built-in-predicates/
          case predicate
          # types
          in [:str?, [[:input, _undefined]]] then {type: "string"}
          in [:int?, [[:input, _undefined]]] then {type: "integer"}
          in [:float? | :decimal?, [[:input, _undefined]]] then {type: "number"}
          in [:bool?, [[:input, _undefined]]] then {type: "boolean"}
          in [:date?, [[:input, _undefined]]] then {type: "date"}
          in [:time?, [[:input, _undefined]]] then {type: "time"}
          in [:date_time?, [[:input, _undefined]]] then {type: "datetime"}
          in [:array?, [[:input, _undefined]]] then {type: "array"}
          in [:hash?, [[:input, _undefined]]] then {type: "object"}
          in [:nil?, [[:input, _undefined]]] then {type: "null"}
          # enum and const
          in [:included_in?, [[:list, Array => list], [:input, _undefined]]] then {enum: list}
          in [:excluded_from?, [[:list, Array => list], [:input, _undefined]]] then {not: {enum: list}}
          in [:eql?, [[:left, left], [:right, _undefined]]] then {value: left, readonly: true} # 変更不可な固定値
          # Numeric type only
          # NOTE: gt?とlt?はintegerであることが前提
          in [:gt?, [[:num, Numeric => num], [:input, _undefined]]] then {min: num + 1}
          in [:gteq?, [[:num, Numeric => num], [:input, _undefined]]] then {min: num}
          in [:lt?, [[:num, Numeric => num], [:input, _undefined]]] then {max: num - 1}
          in [:lteq?, [[:num, Numeric => num], [:input, _undefined]]] then {max: num}
          # String type only
          # NOTE: 本当は異なるがが、sizeとbytesizeは区別しない。
          in [:max_size? | :max_bytesize?, [[:num, Integer => num], [:input, _undefined]]] then {maxlength: num}
          in [:min_size? | :min_bytesize?, [[:num, Integer => num], [:input, _undefined]]] then {minlength: num}
          in [:size? | :bytesize?, [[:size, Integer => size], [:input, _undefined]]]
            {minlength: size, maxlength: size}
          in [:size? | :bytesize?, [[:size, Range => size], [:input, _undefined]]]
            {minlength: size.min, maxlength: size.max}
          in [:format?, [[:regex, Regexp => regex], [:input, _undefined]]]
            {pattern: ruby_regex_to_js_regex(regex)}
          in [:empty?, [[:input, _undefined]]] then {maxlength: 0}
          in [:filled?, [[:input, _undefined]]] then {minlength: 1}
          end
        end

        private def ruby_regex_to_js_regex(ruby_regex)
          ruby_regex.source
            .sub(/\A\\A/, "^")
            .sub(/\\z\z/, "$")
        end
      end
    end
  end
end
