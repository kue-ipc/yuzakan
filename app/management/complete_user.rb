# frozen_string_literal: true

module Yuzakan
  module Management
    class CompleteUser < Yuzakan::Operation
      include Deps[
        "repo.config_repo",
        "repo.affiliation_repo",
        "operations.complete_attrs",
      ]

      def call(name, attrs, primary_group, groups)
        name = step validate_name(name)
        affiliation =
          if primary_group&.affiliation_id
            primary_group.affiliation || affiliation_repo.find(primary_group.affiliation_id)
          end

        attrs = step complete_attrs.call(:user, {name:, attrs:,
          affiliation: affiliation&.to_h&.slice(:name, :attrs),
          primary_group: primary_group&.to_h&.slice(:name, :attrs),
          groups: groups.map { |group| group&.to_h&.slice(:name, :attrs) }.compact})
        label = step get_label(attrs)
        label = name if label.nil? || label.empty?
        email = step get_email(attrs)

        {label:, email:, attrs:}
      end

      private def get_label(attrs)
        config = config_repo.current!
        return Success(nil) if config.user_label_attr.empty?

        label = attrs[config.user_label_attr]
        Success(label)
      end

      private def get_email(attrs)
        config = config_repo.current!
        return Success(nil) if config.user_email_attr.empty?

        email = attrs[config.user_email_attr]
        Success(email)
      end
    end
  end
end
