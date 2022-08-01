require 'hanami/action/cache'

module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action

        security_level 0

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:setup).schema do
              required(:config).schema do
                required(:title).filled(:str?, max_size?: 255)
                required(:domain).maybe(:str?, max_size?: 255)
              end
              required(:admin_user).schema do
                required(:username).filled(:str?, :name?, max_size?: 255)
                required(:password).filled.confirmation
              end
            end
          end
        end

        params Params

        def call(params)
          # unless params.valid?
          #   flash[:errors] = params.errors
          #   redirect_to routes.path(:setup)
          # end

          redirect_to routes.path(:setup) if configurated?

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
      end
    end
  end
end
