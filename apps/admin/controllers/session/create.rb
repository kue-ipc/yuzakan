# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Session
      class Create
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :data

        def call(params)
          result = Authenticate.new(client: remote_ip, app: 'admin')
            .call(params[:session])

          if result.failure?
            if format == :html
              flash[:errors] = result.errors
              flash[:failure] = 'ログインに失敗しました。'
              redirect_to routes.path(:root)
            elsif format == :json
              @data = {
                result: 'failure',
                messages: {
                  errors: result.errors,
                  failure: 'ログインに失敗しました。',
                },
              }
            end
            return
          end

          unless result.user.admin
            session[:user_id] = nil
            if format == :html
              flash[:failure] = '管理者権限がありません。'
              redirect_to routes.path(:root)
            elsif format == :json
              @data = {
                result: 'failure',
                messages: {
                  failure: '管理者権限がありません。',
                },
              }
            end
            return
          end

          session[:user_id] = result.user.id
          session[:access_time] = Time.now
          if format == :html
            flash[:success] = 'ログインしました。'
            redirect_to routes.path(:dashboard)
          elsif format == :json
            @data = {
              result: 'success',
              messages: {success: 'ログインしました。'},
            }
          end
        end

        def authenticate!
        end
      end
    end
  end
end
