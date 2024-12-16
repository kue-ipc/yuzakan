# frozen_string_literal: true

# Userレポジトリと各プロバイダーのユーザー情報同期
module Yuzakan
  module Operations
    class SyncUser < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "repos.user_repo",
        "repos.group_repo",
        "repos.member_repo",
        "provider.read_user",
        "operations.register_user"
      ]

      # class Validator
      #   include Hanami::Validations
      #   predicates NamePredicates
      #   messages :i18n

      #   validations do
      #     required(:username).filled(:str?, :name?, max_size?: 255)
      #   end
      # end

      expose :user
      expose :data
      expose :providers

      def call(username)
        username = step validate(username)
        user_params = step read_from_providers(username)
        user = step sync(username, user_params)
        user
      end

      private def validate(username)
        return Failure(:is_not_string) unless username.is_a?(String)
        return Failure(:invaild_name) unless username =~ /\A[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*\z/

        Success(username)
      end

      private def read_from_providers(username)
        providers = step read_user.call(username)

        return Success(nil) if providers.empty?

        user_params = {attrs: {}, groups: []}
        providers.each_value do |data|
          %i[username display_name email primary_group].each do |name|
            user_params[name] ||= data[name] unless data[name].nil?
          end
          user_params[:groups] |= data[:groups] unless data[:groups].nil?
          user_params[:attrs] = data[:attrs].merge(user_params[:attrs]) unless data[:attrs].nil?
        end
        Success(user_params)
      end

      private def sync(username, user_params)
        if user_params
          step register_user.call(user_params.slice(:username, :display_name, :email, :primary_group, :groups))
        else
          step unregister_user.call(username)
        end
      end
    end
  end
end
