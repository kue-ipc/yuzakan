# frozen_string_literal: true

module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action

        def call(params)
          redirect_to routes.path(:setup_done) if configurated?

          result = InitialSetup.new.call(params[:setup])

          if result.failure?
            flash[:errors] = []
            result.errors.each do |error|
              if error.is_a?(Hash) && error[:params]
                flash[:param_errors] = error
              else
                flash[:errors] << error
              end
            end
            redirect_to routes.path(:setup)
          end
        end

        def configurate!; end

        def authenticate!; end
      end
    end
  end
end
