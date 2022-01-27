module Admin
  module Controllers
    module Users
      class New
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
        end
      end
    end
  end
end
