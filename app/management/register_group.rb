# frozen_string_literal: true

# Groupレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterGroup < Yuzakan::Operation
      include Deps[
        "repo.config_repo",
        "repos.group_repo",
        "repos.managed_group_repo",
        "operations.complete_attrs",
      ]

      def call(groupname, params, time: Time.now)
        groupname = step validate_name(groupname)

        group = group_repo.get_with_associations(groupname)
        affiliation = group&.affiliation

        attrs = step complete_attrs.call(category, {name: :groupname, affiliation:, attrs: params[:attrs]})
        label = step get_label(attrs)
        label = groupname if label.nil? || label.empty?

        group_params = {
          label:,
          attrs:,
          deleted_at: nil,
          synced_at: time
        }

        step register(groupname, {})
      end

      private def get_label(groupname, attrs)
        config = config_repo.current!
        if config.group_label_attr.empty?
          Success(groupname)
        end
        label = attrs[:label]
        return Success(label) if label

        return Failure("label is required for group #{groupname}") unless config_repo.get(:default_group_label)

        Success(config_repo.get(:default_group_label))
      end

      private def register(groupname, params, time: Time.now)
        group_repo.transaction do
          group_params = params.except(:services)
          group = group_repo.set(groupname, **group_params, deleted_at: nil, synced_at: time)
          managed_group_repo.set_services_for_group(group, params[:services]) if params.key?(:services)
        end
        Success(group_repo.get_with_associations(groupname))
      end
    end
  end
end
