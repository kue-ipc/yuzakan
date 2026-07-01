# frozen_string_literal: true

module Yuzakan
  module Management
    class CompleteAffiliation < Yuzakan::Operation
      include Deps[
        "repo.config_repo",
        "operations.complete_attrs",
      ]

      def call(name, attrs)
        name = step validate_name(name)
        attrs = step complete_attrs.call(:affiliation, {name:, attrs:})
        label = step get_label(attrs)
        label = name if label.nil? || label.empty?

        {label:, attrs:}
      end

      private def get_label(attrs)
        config = config_repo.current!
        return Success(nil) if config.affiliation_label_attr.empty?

        label = attrs[config.affiliation_label_attr]
        Success(label)
      end
    end
  end
end
