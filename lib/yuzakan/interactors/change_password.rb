# frozen_string_literal: true

# 自分自身のパスワードのみ変更可能
# パスワードの制限値はconifgで管理
# 強度チェックはzxcvbnを使用

require 'hanami/interactor'
require 'hanami/validations/form'
require 'zxcvbn'

class ChangePassword
  include Hanami::Interactor

  class Validations
    include Hanami::Validations::Form
    messages_path 'config/messages.yml'

    validations do
      required(:password_current).filled
      required(:password).filled.confirmation
      required(:password_confirmation).filled
    end
  end

  expose :user_datas
  expose :count

  def initialize(
    user:,
    client:,
    config: ConfigRepostitory.new.current,
    providers: ProviderRepository.new
      .operational_all_with_params(:change_password),
    activity_repository: ActivityRepository.new,
    mailer: Mailers::ChangePassword
  )
    @user = user
    @client = client
    @config = config
    @providers = providers
    @activity_repository = activity_repository
    @mailer = mailer
  end

  def call(params)
    username = @user.name

    activity_params = {
      user: @user,
      client: @client,
      type: 'user',
      target: username,
      action: 'change_password: ' + @providers.map(&:name).join(','),
    }

    mailer_params = {
      user: @user,
      config: @config,
      by_user: :self,
      action:'パスワード変更',
      description: 'アカウントのパスワードを変更しました。'
    }

    @count = 0
    @user_datas = {}
    result = :success

    @providers.each do |provider|
      user_data =
        provider.adapter.change_password(@user.name, params[:password])
      if user_data
        @user_datas[provider.name] = user_data
        @count += 1
      end
    rescue => e
      if @count.positive?
        error <<~'ERROR_MESSAGE'
          一部のシステムのパスワードは変更されましたが、
          別のシステムの変更時にエラーが発生し、処理が中断されました。
          変更されていないシステムが存在する可能性があるため、
          再度パスワードを変更してください。
          現在のパスワードはすでに変更されている場合があります。
        ERROR_MESSAGE
      end
      error("パスワード変更時にエラーが発生しました。: #{e.message}")
      result = :error
    end

    if @count.zero?
      error('どのシステムでもパスワードは変更されませんでした。')
      result = :failure
    end

    @activity_repository.create(**activity_params, result: result)
    @mailer&.deliver(**mailer_params, result: result)
  end

  private def valid?(params)
    ok = true
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      ok = false
    end

    if params[:password] && !params[:password].empty?
      if params[:password].size < @config.password_min_size
        error({password:
          ['%d文字以上でなければなりません。' % @config.password_min_size]})
        ok = false
      end

      if params[:password].size > @config.password_max_size
        error({password:
          ['%d文字以下でなければなりません。' % @config.password_max_size]})
        ok = false
      end

      if params[:password] !~ /\A[\u0020-\u007e]*\z/ ||
         !((@config.password_unusable_chars&.chars || []) &
           params[:password].chars).empty?
        error({password: ['使用できない文字が含まれています。']})
        ok = false
      end

      if @config.password_min_types > 1
        types = [
          /[0-9]/,
          /[a-z]/,
          /[A-Z]/,
          /[^0-9a-zA-Z]/,
        ].select { |reg| reg.match(params[:password]) }.size
        if types < @config.password_min_types
          error({password:
            ['文字種は%d種類以上でなければなりません。' %
            @config.password_min_types]})
          ok = false
        end
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
        error({password: ['パスワードが弱すぎます。']})
        ok = false
      end
    end

    # 現在のパスワード確認
    if params[:password_current] && !params[:password_current].empty?
      result = Authenticate.new(client: @client,
                                provider_repository: @provider_repository)
        .call(username: @user.name, password: params[:password_current])
      if result.failure?
        error(password_current: ['パスワードが違います。'])
        ok = false
      end
    end

    ok
  end
end
