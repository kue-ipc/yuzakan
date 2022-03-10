require 'set'
require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class Sync
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :counts

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          user_repository = UserRepository.new
          @counts = {}
          user_names = Set.new(user_repository.all.map(&:name))
          @counts[:registered] = user_names.size
          user_names.each do |name|
            user_repository.sync(name)
          end

          providers = ProviderRepository.new.ordered_all_with_adapter_by_operation(:list)
          providers.each do |provider|
            provider.list.each do |name|
              next if user_names.include?(name)

              user_names << name
              user_repository.sync(name)
            end
          end
          @counts[:total] = user_names.size
          @counts[:new] = @counts[:total] - @counts[:registered]
        end
      end
    end
  end
end
