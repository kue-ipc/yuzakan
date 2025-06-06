# frozen_string_literal: true

module Yuzakan
  module Repos
    class ProviderRepo < Yuzakan::DB::Repo
      private def by_name(name) = providers.by_name(normalize_name(name))

      def get(name) = by_name(name).one

      def set(name, **)
        by_name(name).changeset(:update, **).map(:touch).commit ||
          providers.changeset(:create, **, name: normalize_name(name))
            .map(:add_timestamps).commit
      end

      def unset(name) = by_name(name).changeset(:delete).commit

      def exist?(name) = by_name(name).exist?

      private def ordered = providers.order(:order, :name)

      def all = ordered.to_a

      def list = ordered.pluck(:name)

      def all_callable(method)
        abilities = Yuzakan::Structs::Provider.abilities_to(method)
        condition = abilities.to_h { |k| [k, true] }
        ordered.where(condition).to_a
      end

      def mget(*names)
        ordered.where(name: names.map { |name| normalize_name(name) }).to_a
      end

      # TODO: 整理が必要

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
