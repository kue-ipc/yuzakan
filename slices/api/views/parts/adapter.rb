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
              params: {schema: value.class.schema},
            }
          end
        end

        def to_json(...)
          hash = to_h(...)
          hash = {**hash, params: {schema: json_schema}} if hash[:params]
          helpers.params_to_json(hash)
        end

        def json_schema
          value.class.schema.ast => [:set, rules]
          required = []
          properties = rules.to_h do |rule|
            item_required =
              case rule
              in [:and, item]
                true
              in [:implication, item]
                false
              end
            item => [[:predicate, [:key?, [[:name, name], [:input, _undefined]]]], [:key, [_name, Array => ast]]]
            # key = Yuzakan::Utils::String.json_key(name)
            key = name
            required << key if item_required
            [key, ast_to_property(ast, name)]
          end
          {type: "object", properties:, required:}
        end

        private def ast_to_property(ast, name)
          {
            title: context.t("adapters.#{value.name}.params.#{name}.label", default: nil),
            description: context.t("adapters.#{value.name}.params.#{name}.description", default: nil),
            default: value.class.default_params[name],
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
          in [:eql?, [[:left, left], [:right, _undefined]]] then {const: left}
          # Numeric type only
          in [:gt?, [[:num, Numeric => num], [:input, _undefined]]] then {exclusiveMinimum: num}
          in [:gteq?, [[:num, Numeric => num], [:input, _undefined]]] then {minimum: num}
          in [:lt?, [[:num, Numeric => num], [:input, _undefined]]] then {exclusiveMaximum: num}
          in [:lteq?, [[:num, Numeric => num], [:input, _undefined]]] then {maximum: num}
          # String type only
          # NOTE: 実際のところは間違っているが、sizeとbytesizeは区別しない。
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
