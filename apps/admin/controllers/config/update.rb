# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Config
      class Update
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          result = UpdateConfig.new.call(params[:config])

          if result.successful?
            flash[:success] = '設定を変更しました。'
          else
            flash[:errors] = result.errors
            flash[:errors] << '変更に失敗しました。'
          end

          redirect_to routes.path(:edit_config)
        end
      end
    end
  end
end
