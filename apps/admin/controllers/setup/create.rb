require 'hanami/action/cache'

module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          redirect_to routes.path(:setup_done) if configurated?

          result = InitialSetup.new.call(params[:setup])

          if result.failure?
            flash[:errors] = result.errors
            redirect_to routes.path(:setup)
          end

          flash[:success] = '初期セットアップが完了しました。' \
                            '管理者でログインしてください。'
        end

        def configurate!
        end

        def authenticate!
        end
      end
    end
  end
end
