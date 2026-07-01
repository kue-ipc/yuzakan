# frozen_string_literal: true

module Yuzakan
  module Management
    class CompleteGroup < Yuzakan::Operation
      include Deps[
        "repo.config_repo",
        "operations.complete_attrs",
      ]

      def call(name, attrs, affiliation)
        name = step validate_name(name)
        attrs = step complete_attrs.call(:group, {name:, attrs:,
          affiliation: affiliation&.to_h&.slice(:name, :attrs)})
        label = step get_label(attrs)
        label = name if label.nil? || label.empty?

        {label:, attrs:}
      end

      private def get_label(attrs)
        config = config_repo.current!
        return Success(nil) if config.group_label_attr.empty?

        label = attrs[config.group_label_attr]
        Success(label)
      end
    end
  end
end
