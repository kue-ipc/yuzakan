# frozen_string_literal: true

module API
  module Actions
    module Users
      class Create < API::Action
        include Deps[
          "repos.user_repo",
          "services.service_create_user",
          view: "views.users.show",
        ]

        security_level 4

        contract do
          params do
            required(:name).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:password).filled(:str?, max_size?: MAX_STRING_SIZE)
            optional(:label).value(:str?, max_size?: MAX_STRING_SIZE)
            optional(:email).value(:email, max_size?: MAX_STRING_SIZE)

            optional(:note).value(:str?, max_size?: 4096)
            optional(:clearance_level).filled(:int?)
            optional(:prohibited).filled(:bool?)
            optional(:deleted).filled(:bool?)
            optional(:deleted_at).filled(:date_time?)

            optional(:primary_group).maybe(:name, max_size?: MAX_STRING_SIZE)
            optional(:groups).each(:name, max_size?: MAX_STRING_SIZE)

            optional(:attrs) { hash? }
          end

          rule(:name).validate(:name)
        end

        def handle(_request, _response)
          halt_json 400, errors: [params.errors] unless params.valid?

          @name = params[:name]
          load_user
          halt_json 422, errors: {name: [t("errors.uniq?")]} if @user

          if params[:services] && params[:attrs].nil?
            halt_json 422,
              errors: {attrs: t("errors.filled?")}
          end

          password = params[:password] || generate_password.password

          if params[:deleted]
            # どのプロバイダーにも登録しない削除済みユーザーの作成する。
            # プロバイダーの指定は無視する。
            # 削除日時が指定されていない場合は現在の日時を削除日時とする。
            @user = @user_repository.create({deleted_at: Time.now,
                                             **params.to_h.except(:id)})
          elsif params[:services]&.size&.positive?
            @user = @user_repository.create(params.to_h.except(:id))
            service_create_user({
              **params.to_h,
              username: @name,
              password: password,
            })
          else
            halt_json 422,
              errors: {services: [t("errors.min_size?", num: 1)]}
          end

          load_user

          self.status = 201
          headers["Content-Location"] = routes.user_path(@user.name)
          self.body = user_json(password: password)
        end

        def handle_google(_request, _response)
          unless params.get(:agreement)
            flash[:failure] = "同意がありません。"
            redirect_to routes.path(:google)
          end

          service = ServiceRepository.new.first_google_with_adapter

          result = ServiceCreateUser.new(user: current_user, client: client,
            config: current_config,
            services: [service])
            .call(params.get(:google_create))

          if result.failure?
            flash[:errors] = result.errors
            flash[:failure] = "Google アカウント の作成に失敗しました。"
            redirect_to routes.path(:google)
          end

          @user = result.user_datas[service.name]
          @password = result.password

          flash[:success] = "Google アカウント を作成しました。"
        end
      end
    end
  end
end
