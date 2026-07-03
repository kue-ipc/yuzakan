# frozen_string_literal: true

module Yuzakan
  module Operations
    # Complete attrs
    class CompleteAttrs < Yuzakan::Operation
      include Deps[
        "repos.attr_repo",
        "handlebars",
      ]

      def call(category, data)
        category = step validate_category(category)
        step complete_attrs(category, data)
      end

      private def validate_category(category)
        if Yuzakan::Relations::Attrs::CATEGORIES.include?(category)
          Success(category)
        else
          Failure[:invalid,
            {category: [t("errors.included_in?", list: Yuzakan::Relations::Attrs::CATEGORIES.join(", "))]}]
        end
      end

      private def complete_attrs(category, data)
        attrs = {}
        attr_repo.all_for_category(category).to_h do |attr|
          name = attr.name
          value = data[:attrs][name]
          attrs[name] =
            if attr.readonly || code.empty? || (value && !attr.forced)
              value
            else
              complete_attr(attr, data, attrs)
            end
        end
        Success(attrs.compact)
      end

      private def complete_attr(attr, data, attrs)
        hash = {**data, attrs:}
        template = handlebars.compile(attr.code, noEscape: true)
        value = template.call(hash)
        convert_type(value, attr.type)
      end

      private def convert_type(value, type)
        case type
        when "boolean"
          if TRUE_VALUES.include?(value)
            true
          elsif FALSE_VALUES.include?(value)
            false
          end
        when "string"
          value.to_s
        when "integer"
          value.to_i
        when "float"
          value.to_f
        when "date"
          value.to_date
        when "time", "datetime"
          value.to_time
        else
          value
        end
      end
    end
  end
end
