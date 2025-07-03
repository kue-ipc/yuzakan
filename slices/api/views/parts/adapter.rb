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
              lable: context.t("adapters.#{value.adapter_name}.params.#{name}.label", default: name.to_s),
              description: context.t("adapters.#{value.adapter_name}.params.#{name}.description", default: nil),
              required:,
              **parse_ast(ast),
            }
          end
        end

        private def parse_ast(ast)
          warn ast.inspect
          case ast
          in [:predicate, predicate]
            convert_predicate(predicate)
          in [:and, Array => nested_asts]
            {}.merge(*nested_asts.map { |nested_ast| parse_ast(nested_ast) })
          in [:implication, [:not, [:predicate, [:nil?, [[:input, _undefined]]]]], nested_ast]
            {**parse_ast(nested_ast), maybe: true}
          end
        end

        private def convert_predicate(predicate)
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
          in [:eql?, [[:left, value], [:right, _undefined]]] then {value:}
          in [:empty?, [[:input, _undefined]]] then {empty: true}
          in [:filled?, [[:input, _undefined]]] then {filled: true}
          # in [:gt?, [[:num, Numeric => value], [:input, _undefined]]] then {min: value}
          in [:gteq?, [[:num, Numeric => value], [:input, _undefined]]] then {min: value}
          # in [:lt?, [[:num, Numeric => value], [:input, _undefined]]] then {max: value}
          in [:lteq?, [[:num, Numeric => value], [:input, _undefined]]] then {max: value}
          in [:max_size?, [[:num, Numeric => value], [:input, _undefined]]] then {maxlength: value}
          in [:min_size?, [[:num, Numeric => value], [:input, _undefined]]] then {minlength: value}
          in [:size?, [[:size, Numeric => value], [:input, _undefined]]] then {minlength: value, maxlength: value}
          in [:size?, [[:size, Range => value], [:input, _undefined]]] then {minlength: value.min, maxlength: value.max}
          in [:format?, [[:regex, Regexp => value], [:input, _undefined]]] then {format: value.source}
          in [:includeded_in?, [[:list, Array => value], [:input, _undefined]]] then {included_in: value}
          in [:excluded_from?, [[:list, Array => value], [:input, _undefined]]] then {excluded_from: value}
          end
        end
      end
    end
  end
end
