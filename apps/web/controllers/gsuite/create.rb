# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      class Create
        include Web::Action

        params do
          required(:agreement) { filled? & bool? }
        end

        expose :user
        expose :password

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

          user_attrs = UserAttrs.new.call(username: current_user.name).attrs
          if user_attrs.nil?
            flash[:failure] = 'ユーザーの情報がありません。'
            redirect_to routes.path(:gsuite)
          end

          user_attrs = current_user.to_h.merge(user_attrs)

          @password = SecureRandom.alphanumeric(16)
          @user = gsuite_repository.adapter.create(
            current_user.name,
            user_attrs,
            ProviderAttrMappingRepository.new
              .by_provider_with_attr_type(gsuite_repository.id),
            @password)
        end
      end
    end
  end
end
