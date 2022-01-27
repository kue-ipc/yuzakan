module Admin
  module Controllers
    module Users
      class Search
        include Admin::Action
        include Hanami::Action::Cache
        include Yuzakan::Helpers::NameChecker

        cache_control :no_store

        def call(params)
          query = params[:q]
        end
      end
    end
  end
end
