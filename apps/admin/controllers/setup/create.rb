# frozen_string_literal: true

module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action

        def call(params)
          redirect_to routes.path(:setup_done) if configurated?

          if ConfigRepository.new.initialized?
            redirect_to routes.path(:setup_done)
          end

          result = InitialSetup.new.call(params[:admin_user])

          if result.success?
            redirect_to routes.path(:setup_done)
          else
            flash[:errors] = result.errors
            redirect_to routes.path(:setup)
          end
        end

        def configurate!; end
        def authenticate!; end
      end
    end
  end
end
