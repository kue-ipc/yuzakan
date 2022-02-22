# 自分自身のパスワードのみ変更可能
# パスワードの制限値はconifgで管理
# 強度チェックはzxcvbnを使用

require 'hanami/interactor'
require 'hanami/validations/form'
require 'zxcvbn'

class CheckChangePassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:current_password).filled
      required(:password).filled.confirmation
      required(:password_confirmation).filled
    end
  end

  def initialize(connection_info:, provider_repository: ProviderRepository.new)
    @connection_info = connection_info
    @provider_repository = provider_repository
  end

  expose :username
  expose :password

  def call(params)
    # 現在のパスワード確認
    authenticate = Authenticate.new(provider_repository: @provider_repository)
    result = authenticate.call(username: @connection_info[:user].name, password: params[:current_password])
    error!(current_password: ['パスワードが違います。']) if result.failure?

    @username = @connection_info[:user].name
    @password = params[:password]
  end

  private def valid?(params)
    ok = true
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      ok = false
    end

    if params[:password] && !params[:password].empty?
      if params[:password].size < @connection_info[:config].password_min_size
        error({password: ['%d文字以上でなければなりません。' % @connection_info[:config].password_min_size]})
        ok = false
      end

      if params[:password].size > @connection_info[:config].password_max_size
        error({password: ['%d文字以下でなければなりません。' % @connection_info[:config].password_max_size]})
        ok = false
      end

      if params[:password] !~ /\A[\u0020-\u007e]*\z/ ||
         !((@connection_info[:config].password_unusable_chars&.chars || []) && params[:password].chars).empty?
        error({password: ['使用できない文字が含まれています。']})
        ok = false
      end

      if @connection_info[:config].password_min_types > 1
        types = [
          /[0-9]/,
          /[a-z]/,
          /[A-Z]/,
          /[^0-9a-zA-Z]/,
        ].select { |reg| reg.match(params[:password]) }.size
        if types < @connection_info[:config].password_min_types
          error({password: ['文字種は%d種類以上でなければなりません。' % @connection_info[:config].password_min_types]})
          ok = false
        end
      end

      dict = (@connection_info[:config].password_extra_dict&.split || []) +
             [
               @connection_info[:user].name,
               @connection_info[:user].display_name&.split,
               @connection_info[:user].email,
               @connection_info[:user].email&.split('@'),
               params[:current_password],
             ].flatten.compact

      result = Zxcvbn.test(params[:password], dict)
      if result.score < @connection_info[:config].password_min_score
        error({password: ['パスワードが弱すぎます。']})
        ok = false
      end
    end

    ok
  end
end
