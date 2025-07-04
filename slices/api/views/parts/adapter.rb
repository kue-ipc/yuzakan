# auto_register: false
# frozen_string_literal: true

require "hanami/utils/json"

module API
  module Views
    module Parts
      class Adapter < API::Views::Part
        def to_h
          {
            name: value.adapter_name,
            label: value.label,
            group: value.has_group?,
            primary: value.has_primary_group?,
            params: {schema: dry_schema},
          }
        end

        def to_json(...)
          helpers.params_to_json({
            **to_h.except(:params),
            params: {schema: json_schema},
          }, ...)
        end

        def dry_schema
          value.schema
        end

        def json_schema
          dry_schema.ast => [:set, rules]
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
            key = Yuzakan::Utils::String.json_key(name)
            required << key if item_required
            [key, ast_to_property(ast, name)]
          end
          {type: "object", properties:, required:}
        end

        private def ast_to_property(ast, name)
          {
            title: context.t("adapters.#{value.adapter_name}.params.#{name}.label", default: nil),
            description: context.t("adapters.#{value.adapter_name}.params.#{name}.description", default: nil),
            default: value.default_params[name],
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
          in [:max_size? | :max_bytesize?, [[:num, Integer => num], [:input, _undefined]]] then {maxLength: num}
          in [:min_size? | :min_bytesize?, [[:num, Integer => num], [:input, _undefined]]] then {minLength: num}
          in [:size? | :bytesize?, [[:size, Integer => size], [:input, _undefined]]]
            {minLength: size, maxLength: size}
          in [:size? | :bytesize?, [[:size, Range => size], [:input, _undefined]]]
            {minLength: size.min, maxLength: size.max}
          in [:format?, [[:regex, Regexp => regex], [:input, _undefined]]]
            {pattern: ruby_regex_to_js_regex(regex)}
          in [:empty?, [[:input, _undefined]]] then {maxLength: 0}
          in [:filled?, [[:input, _undefined]]] then {minLength: 1}
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
