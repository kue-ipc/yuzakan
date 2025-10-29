# frozen_string_literal: true

module Yuzakan
  module Repos
    class ServiceRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = services.to_a
      def find(id) = services.by_pk(id).one
      def first = services.first
      def last = services.last
      def clear = services.delete

      # common interfaces
      private def by_name(name) = services.by_name(name)
      def get(name) = by_name(name).one
      def set(name, **) = by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**) || create(name: name, **)
      def unset(name) = by_name(name).command(:delete).call
      def exist?(name) = by_name(name).exist?
      def list = services.pluck(:name)

      # other interfaces
      def all_with_abilities(*abilities)
        condition = abilities.to_h { |k| [k, true] }
        services.where(condition).to_a
      end

      def mget(*names)
        services.where(name: names.map { |name| name }).to_a
      end

      def renumber_order(service)
        return 0 if services.where(order: service.order).count < 2

        count = 0
        transaction do
          # OPTIMIZE: N+1 問題があるが、ROMではこの方法しかない。
          services.exclude(id: service.id)
            .where { order >= service.order }
            .each.with_index do |a, idx|
            new_order = service.order + idx + 1
            next if a.order == new_order

            update(a.id, order: new_order)
            count += 1
          end
        end
        count
      end


      # TODO: 整理が必要

      def find_by_name(name)
        by_name(name).one
      end

      def exist_by_name?(name)
        by_name(name).exist?
      end

      def all_individual_password
        services.where(individual_password: true).to_a
      end

      def ordered_all_group
        services.where(group: true).order(:order, :name).to_a
      end

      def find_with_params(id)
        aggregate(:adapter_params).where(id: id).map_to(Service).one
      end

      def find_with_params_by_name(name)
        aggregate(:adapter_params).where(name: name).map_to(Service).one
      end

      def add_param(service, data)
        assoc(:adapter_params, service).add(data)
      end

      private def param_by_name(service, param_name)
        assoc(:adapter_params, service).where(name: param_name)
      end

      def delete_param_by_name(service, param_name)
        param_by_name(service, param_name).delete
      end

      def last_order
        services.order(:order).last&.fetch(:order).to_i
      end

      def ordered_all_with_adapter
        aggregate(:adapter_params, mappings: :attr).order(:order,
          :name).map_to(Service).to_a
      end

      def find_with_adapter(id)
        aggregate(:adapter_params,
          mappings: :attr).where(id: id).map_to(Service).one
      end

      def find_with_adapter_by_name(name)
        aggregate(:adapter_params,
          mappings: :attr).where(name: name).map_to(Service).one
      end

      def first_google
        services
          .where(adapter: "google")
          .where(self_management: true)
          .order(:order)
          .first
      end

      def first_google_with_adapter
        aggregate(:adapter_params, mappings: :attr)
          .where(adapter: "google")
          .where(self_management: true)
          .order(:order)
          .map_to(Service)
          .first
      end

      def ordered_all_with_adapter_self_management
        aggregate(:adapter_params, mappings: :attr).where(self_management: true)
          .order(:order, :name).as(Service).to_a
      end

      def ordered_all_self_management
        services.where(self_management: true).order(:order, :name).to_a
      end
    end
  end
end
