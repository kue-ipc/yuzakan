# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      module Code
        class Create
          include Web::Action

          expose :codes

          def call(_params)
            gsuite_repository = ProviderRepository.new.first_gsuite_with_params

            @codes = gsuite_repository.adapter
              .user_verification_codes(current_user.name)

            unless @codes
              flash[:failure] = 'バックアップコードの生成に失敗しました。'
              redirect_to routes.path(:gsuite)
            end

            flash[:success] = 'バックアップコードを生成しました。'
          end
        end
      end
    end
  end
end
