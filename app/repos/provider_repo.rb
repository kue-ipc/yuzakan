# frozen_string_literal: true

module Yuzakan
  module Repos
    class ProviderRepo < Yuzakan::DB::Repo
      def get(name)
        providers.by_name(name).one
      end

      def set(name, **)
        providers.by_name(name).changeset(:update, **).map(:touch).commit ||
          providers.changeset(:create, **, name: name).map(:add_timestamps)
            .commit
      end

      def unset(name)
        providers.by_name(name).changeset(:delete).commit
      end

      def all
        providers.to_a
      end

      def ordered_all
        providers.order(:order, :name).to_a
      end

      # TODO: 整理が必要

      private def by_name(name)
        providers.where(name: name)
      end

      def find_by_name(name)
        by_name(name).one
      end

      def exist_by_name?(name)
        by_name(name).exist?
      end

      def all_individual_password
        providers.where(individual_password: true).to_a
      end

      def ordered_all_group
        providers.where(group: true).order(:order, :name).to_a
      end

      def find_with_params(id)
        aggregate(:adapter_params).where(id: id).map_to(Provider).one
      end

      def find_with_params_by_name(name)
        aggregate(:adapter_params).where(name: name).map_to(Provider).one
      end

      def add_param(provider, data)
        assoc(:adapter_params, provider).add(data)
      end

      private def param_by_name(provider, param_name)
        assoc(:adapter_params, provider).where(name: param_name)
      end

      def delete_param_by_name(provider, param_name)
        param_by_name(provider, param_name).delete
      end

      def last_order
        providers.order(:order).last&.fetch(:order).to_i
      end

      def ordered_all_with_adapter
        aggregate(:adapter_params, attr_mappings: :attr).order(:order,
          :name).map_to(Provider).to_a
      end

      def find_with_adapter(id)
        aggregate(:adapter_params,
          attr_mappings: :attr).where(id: id).map_to(Provider).one
      end

      def find_with_adapter_by_name(name)
        aggregate(:adapter_params,
          attr_mappings: :attr).where(name: name).map_to(Provider).one
      end

      def ordered_all_with_adapter_by_operation(operation)
        ordered_all_with_adapter_by_ability(Provider.operation_ability(operation))
      end

      def ordered_all_with_adapter_by_ability(ability)
        aggregate(:adapter_params, attr_mappings: :attr).where(ability).order(
          :order, :name).map_to(Provider).to_a
      end

      def first_google
        providers
          .where(adapter: "google")
          .where(self_management: true)
          .order(:order)
          .first
      end

      def first_google_with_adapter
        aggregate(:adapter_params, attr_mappings: :attr)
          .where(adapter: "google")
          .where(self_management: true)
          .order(:order)
          .map_to(Provider)
          .first
      end

      def ordered_all_with_adapter_self_management
        aggregate(:adapter_params, attr_mappings: :attr).where(self_management: true)
          .order(:order, :name).as(Provider).to_a
      end

      def ordered_all_self_management
        providers.where(self_management: true).order(:order, :name).to_a
      end
    end
  end
end
