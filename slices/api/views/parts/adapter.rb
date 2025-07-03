# auto_register: false
# frozen_string_literal: true

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
            params: params,
          }
        end

        def to_json(...) = helpers.params_to_json(to_h)

        def params
          value.schema.to_ast => [:set, rules]
          rules.map do |rule|
            required =
              case rule
              in [:and, item]
                true
              in [:implication, item]
                false
              end
            item => [[:predicate, [:key?, [[:name, name], [:input, _undefined]]]], [:key, [_name, Array => ast]]]
            {
              name:,
              label: context.t("adapters.#{value.adapter_name}.params.#{name}.label", default: name.to_s),
              description: context.t("adapters.#{value.adapter_name}.params.#{name}.description", default: nil),
              required:,
              **parse_ast(ast, name),
            }
          end
        end

        private def parse_ast(ast, name)
          case ast
          in [:predicate, predicate]
            convert_predicate(predicate, name)
          in [:and, Array => nested_asts]
            {}.merge(*nested_asts.map { |nested_ast| parse_ast(nested_ast, name) })
          in [:implication, [:not, [:predicate, [:nil?, [[:input, _undefined]]]]], nested_ast]
            {**parse_ast(nested_ast, name), maybe: true}
          end
        end

        private def convert_predicate(predicate, name)
          # https://dry-rb.org/gems/dry-schema/main/basics/built-in-predicates/
          case predicate
          in [:str?, [[:input, _undefined]]] then {type: "string"}
          in [:int?, [[:input, _undefined]]] then {type: "integer"}
          in [:float?, [[:input, _undefined]]] then {type: "float"}
          in [:decimal?, [[:input, _undefined]]] then {type: "decimal"}
          in [:bool?, [[:input, _undefined]]] then {type: "boolean"}
          in [:date?, [[:input, _undefined]]] then {type: "date"}
          in [:time?, [[:input, _undefined]]] then {type: "time"}
          in [:date_time?, [[:input, _undefined]]] then {type: "datetime"}
          in [:array?, [[:input, _undefined]]] then {type: "array"}
          in [:hash?, [[:input, _undefined]]] then {type: "hash"}
          in [:nil?, [[:input, _undefined]]] then {type: "null"}
          in [:eql?, [[:left, left], [:right, _undefined]]] then {value: left}
          in [:empty?, [[:input, _undefined]]] then {empty: true}
          in [:filled?, [[:input, _undefined]]] then {filled: true}
          in [:gt?, [[:num, Integer => num], [:input, _undefined]]] then {min: num + 1}
          in [:gteq?, [[:num, Numeric => num], [:input, _undefined]]] then {min: num}
          in [:lt?, [[:num, Integer => num], [:input, _undefined]]] then {max: num - 1}
          in [:lteq?, [[:num, Numeric => num], [:input, _undefined]]] then {max: num}
          in [:max_size?, [[:num, Integer => num], [:input, _undefined]]] then {maxlength: num}
          in [:min_size?, [[:num, Integer => num], [:input, _undefined]]] then {minlength: num}
          in [:size?, [[:size, Integer => size], [:input, _undefined]]] then {minlength: size, maxlength: size}
          in [:size?, [[:size, Range => size], [:input, _undefined]]] then {minlength: size.min, maxlength: size.max}
          in [:format?, [[:regex, Regexp => regex], [:input, _undefined]]] then {format: regex.source}
          in [:included_in?, [[:list, Array => list], [:input, _undefined]]]
            list = list.map do |item|
              {name: item, label: context.t("adapters.#{value.adapter_name}.params.#{name}.list.#{item}")}
            end
            {list:}
            # in [:excluded_from?, [[:list, Array => value], [:input, _undefined]]] then {excluded_from: value}
          end
        end
      end
    end
  end
end
