# frozen_string_literal: true

module Yuzakan
  module Repos
    class AdapterParamRepo < Yuzakan::DB::Repo
      def all_by_provider(provider)
        all_by_provider_id(provider.id)
      end

      def all_by_provider_id(provider_id)
        adapter_params.by_provider_id(provider_id).to_a
      end

      def all_by_provider_name(provider_name)
        adapter_params.join(providers).where("provider.name" => provider_name)
          .to_a
      end


    # TODO: 整理が必要


      def find_by_provider_and_name(data)
        adapter_params
          .where(provider_id: data[:provider_id] || data[:provider].id)
          .where(name: data[:name])
          .one
      end

      def create_or_update(data)
        entry = find_by_provider_and_name(data)
        if entry
          update(entry.id, data)
        else
          create(data)
        end
      end

    end
  end
end
