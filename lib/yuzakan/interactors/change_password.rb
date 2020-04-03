# frozen_string_literal: true

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

  expose :count

  def initialize(user:,
                 client: nil,
                 config: ConfigRepostitory.new.current,
                 provider_repository: ProviderRepository.new,
                 job_repository: JobRepository.new)
    @user = user
    @client = client
    @config = config
    @provider_repository = provider_repository
    @job_repository = job_repository
  end

  def call(password:, **_)
    job = @job_repository.job_create(owner: @user,
                                     client: @client,
                                     user: @user,
                                     action: 'change_password',
                                     params: nil)
    @count = 0

    @job_repository.job_begin(job.id)
    @provider_repository.operational_all_with_params(:change_password)
      .each do |provider|
      @count += 1 if provider.adapter.change_password(@user.name, password)
    rescue => e
      @job_repository.job_errored(job.id)
      if @count.positive?
        error <<~'ERROR_MESSAGE'
          一部のシステムのパスワードは変更されましたが、
          エラーにより処理が中断されました。
          変更されていないシステムが存在する可能性があるため、
          再度パスワードを変更してください。
          現在のパスワードはすでに変更されている場合があります。
        ERROR_MESSAGE
      end
      error!("パスワード変更時にエラーが発生しました。: #{e.message}")
    end

    if @count.negative?
      @job_repository.job_failed(job.id)
      error! <<~'ERROR_MESSAGE'
        どのシステムでもパスワードは変更されませんでした。
      ERROR_MESSAGE
    end

    @job_repository.job_succeeded(job.id)
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
          '%d文字以上でなければなりません。' % @config.password_min_size})
        ok = false
      end

      if params[:password].size > @config.password_max_size
        error({password:
          '%d文字以下でなければなりません。' % @config.password_max_size})
        ok = false
      end

      if params[:password] !~ /\A[\u0020-\u007e]*\z/ ||
          !((@config.password_unusable_chars&.chars || []) &
            params[:password].chars).empty?
        error({password: '使用できない文字が含まれています。'})
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
            '文字種は%d種類以上でなければなりません。' %
            @config.password_min_types})
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
        error({password: 'パスワードが弱すぎます。'})
        ok = false
      end
    end

    # 現在のパスワード確認
    if params[:password_current] && !params[:password_current].empty?
      result = Authenticate.new(
        owner: @user,
        client: @client,
        provider_repository: @provider_repository
      ).call(
        username: @user.name,
        password: params[:password_current],
      )
      if result.failure?
        error(password_current: 'パスワードが違います。')
        ok = false
      end
    end

    ok
  end
end
