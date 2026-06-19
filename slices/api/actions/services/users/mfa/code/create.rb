# frozen_string_literal: true

module API
  module Actions
    module Services
      module Users
        module Mfa
          module Code
            class Create < API::Action
            incrlude Deps[
              "repos.service_repo",
              "repos.user_repo",
              "services.generate_code_user",
            ]

            security_level 1

            params do
              required(:service_id).filled(:name, max_size?: MAX_STRING_SIZE)
              required(:user_id) { filled(:name, max_size?: 255) | eql?("~") }
            end

            def handle(request, response)
              check_params(request, response)

              service = srevice_repo.get!(request.params[:service_id])

              user =
                if request.params[:user_id] == "~"
                  # current user mode
                  response[:current_user]
                else
                  # can generate code for other users by operator
                  reply_unauthorized(request, response) unless response[:current_level] >= 3

                  user_repo.get!(request.params[:user_id])
                end

              result = generate_code_user.call(service, user.name)
              code = take_result(request, response, result)

              response.status = :created
              response.format = :json
              response.body = code.to_json
            end
          end
        end
        end
      end
    end
  end
end


# def handle(_request, response)
#                 response.body = self.class.name
#               end

#               def old_handle(_request, _response)
#                 service = ServiceRepository.new.first_google_with_adapter

#                 result = GenerateVerificationCode.new(
#                   user: current_user,
#                   client: client,
#                   config: current_config,
#                   services: [service]).call(params.get(:google_code_create))

#                 if result.failure?
#                   flash[:errors] = result.errors
#                   flash[:failure] = "バックアップコードの生成に失敗しました。"
#                   redirect_to routes.path(:google)
#                 end

#                 @codes = result.user_datas[service.name]
#                 flash[:success] = "バックアップコードを生成しました。"
#               end

#               # TODO: メール送信、未整理
#               def send_mail
#                 activity_params = {
#                   user_id: @user.id,
#                   client: @client,
#                   type: "user",
#                   target: @username,
#                   action: "generate_code",
#                 }

#                 by_user =
#                   if @username == @user.name
#                     :self
#                   else
#                     :admin
#                   end

#                 mailer_params = {
#                   user: @user,
#                   config: @config,
#                   by_user: by_user,
#                   action: "バックアップコード生成",
#                   description: "バックアップコードを生成しました。",
#                 }

#                 activity_params[:action] += ":#{@services.map(&:name).join(',')}"
#                 mailer_params[:services] = @services

#                 @user_datas = {}
#                 result = :success

#                 @services.each do |service|
#                   user_data = service.user_generate_code(@username)
#                   @user_datas[service.name] = user_data if user_data
#                 rescue => e
#                   logger.error e
#                   error("バックアップコード生成時にエラーが発生しました。: #{e.message}")
#                   result = :error
#                 end

#                 if @user_datas.empty?
#                   error("どのシステムでもバックアップコードは生成されませんでした。")
#                   result = :failure
#                 end

#                 @activity_repository.create(**activity_params, result: result.to_s)
#                 @mailer&.deliver(**mailer_params, result: result)
#               end

#               # TODO: 独自のバリデーション
#               def check
#                 unless @services&.all?(&:self_management)
#                   error("自己管理可能なシステム以外でバックアップコードを生成することはできません。")
#                   return false
#                 end

#                 if params&.key?(:username) && params[:username] != @user.name
#                   error(username: "自分自身以外のバックアップコードを生成することはできません。")
#                   return false
#                 end

#                 true
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end
