# frozen_string_literal: true

module Yuzakan
  module Operations
    include Deps["repos.attr_repo"]

    # Complete attrs
    class CompleteAttrs < Yuzakan::Operation
      def call(category, data)
        category = step validate_category(category)
        name = step validate_name(name)
        step complete_attrs(category, name, attrs)
      end

      private def validate_category(category)
        if Yuzakan::Relations::Attrs::CATEGORIES.include?(category)
          Success(category)
        else
          Failure[:invalid,
            {category: [t("errors.included_in?", list: Yuzakan::Relations::Attrs::CATEGORIES.join(", "))]}]
        end
      end

      private def complete_attrs(category, name, attrs)
        completed_attrs = attr_repo.all_for_category(category).to_h do |attr|
          value = attrs[attr.name] = attr_repo.get_exposed(category:, name: attr.name) if attrs.key?(attr.name)

          [attr.name, value]
        end
        Success(completed_attrs)
      end

      private def complete_attr(category, name, attr_name, attrs)
      end
    end
  end
end
