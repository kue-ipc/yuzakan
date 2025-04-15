# frozen_string_literal: true

module Admin
  module Actions
    module Config
      class New < Admin::Action
        security_level 0

        expose :config
        expose :admin_user

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          flash[:errors] ||= []

          if configurated?
            flash[:errors] << t("errors.already_initialized")
            redirect_to Web.routes.path(:root)
          end

          @config = {}
          @admin_user = {}
        end

        def configurate!
        end
      end
    end
  end
end
