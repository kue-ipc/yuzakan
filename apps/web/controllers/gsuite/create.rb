# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      class Create
        include Web::Action

        params do
          required(:agreement) { filled? & bool? }
        end

        def call(params)
          unless params.get(:agreement)
            flash[:failure] = '同意がありません。'
            redirect_to routes.path(:gsuite)
          end

          gsuite_repository = ProviderRepository.new.first_gsuite_with_params
          gsuite_user = gsuite_repository.adapter.read(current_user.name)
          if gsuite_user
            flash[:failure] = '既に作成済みです。'
            redirect_to routes.path(:gsuite)
          end

          



        end
      end
    end
  end
end
