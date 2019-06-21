# frozen_string_literal: true

# パスワードの制限値について
# configで持たせるべきでは？
# 8以上 32以下
# zxcvbnも使用

require 'hanami/interactor'
require 'hanami/validations'
require 'zxcvbn'

class PasswordChange
  include Hanami::Interactor

  class Validaiton
    include Hanami::Validations

    predicate :strong?, message: 'パスワードが弱すぎます。' do |current|
      result = Zxcvbn.test(current)
      result.score >= 3
    end

    validations do
      required(:username) { filled? }
      required(:password_current) { filled? }
      required(:password).filled(
        :strong?,
        min_size?: 8,
        max_size?: 32
      ).confirmation
    end
  end

  def initialize(provider_repository: ProviderRepository.new)
    @provider_repository = provider_repository
  end

  def call(username:, password:)
    @provider_repository.operational_all_with_params(:change_password)
      .each do |provider|
        provider.adapter.change_password(username, password)
      end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(params: validation.messages)
      return false
    end

    # 現在のパスワード確認
    result = Authenticate.new(provider_repository: @provider_repository).call(
      username: params[:username],
      password: params[:password_current],
    )
    if result.failure?
      error('現在のパスワードが違います。')
      return false
    end
    true
  end
end
