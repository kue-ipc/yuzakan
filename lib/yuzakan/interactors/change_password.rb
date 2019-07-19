# frozen_string_literal: true

# パスワードの制限値について
# configで持たせるべきでは？
# 8以上 32以下
# zxcvbnも使用

require 'hanami/interactor'
require 'hanami/validations/form'
require 'zxcvbn'

class ChangePassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form

    validations do
      required(:password_current).filled
      required(:password).filled.confirmation
      required(:password_confirmation).filled
    end
  end

  expose :count

  def initialize(
      user:,
      config: ConfigRepostitory.new.current,
      provider_repository: ProviderRepository.new
    )
    @user = user
    @config = config
    @provider_repository = provider_repository
  end

  def call(password:, **_opts)
    @count = 0
    @provider_repository.operational_all_with_params(:change_password)
      .each do |provider|
        if provider.adapter.change_password(user.name, password)
          @count += 1
        end
      rescue => e
        error!('エラーが発生しました。')
      end
  end

  private def valid?(params)
    ok = true
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      ok = false
    end

    if params[:password].size < @config.password_min_size
      error({password:
        '%d文字以上でなければなりません。' % @config.password_min_size})
      ok = false
    end

    if params[:password].size > @config.password_max_size
      error({password:
        '%d文字以下でなければなりません。' % @config.password_max_size})
      ok = false
    end

    if params[:passowrd] != /\A[\u0020-\u007e]*\z/ ||
        !(@config.password_unusable_chars.chars -
            params[:passowrd].chars).empty?
      error({password: '使用できない文字が含まれています。'})
      ok = false
    end

    dict = (@config.password_extra_dict&.split || []) +
      [
        @user.name,
        @user.display_name&.split,
        @user.email,
        @user.email&.split('@'),
        params[:password_current],
      ].flatten.compact

    result = Zxcvbn.test(params[:password], dict)
    if result.score < @config.password_min_score
      error({password: 'パスワードが弱すぎます。'})
      ok = false
    end

    # 現在のパスワード確認
    pp @user
    result = Authenticate.new(provider_repository: @provider_repository).call(
      username: @user.name,
      password: params[:password_current],
    )
    if result.failure?
      error(password_current: 'パスワードが違います。')
      ok = false
    end
    ok
  end
end
