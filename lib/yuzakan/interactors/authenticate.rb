# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class Authenticate
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:username) { filled? }
      required(:password) { filled? }
    end
  end

  expose :user

  def initialize(owner: nil,
                 client: nil,
                 user_repository: UserRepository.new,
                 provider_repository: ProviderRepository.new,
                 job_repository: JobRepository.new)
    @owner = owner
    @client = client
    @user_repository = user_repository
    @provider_repository = provider_repository
    @job_repository = job_repository
  end

  def call(username:, password:, **_)
    # パラメーターはユーザー名のみを記録する。
    # ユーザーは未定のままにする。
    job = @job_repository.job_create(owner: @owner,
                                     client: @client,
                                     user: nil,
                                     action: 'authenticate',
                                     params: username)
    user_data = nil

    @job_repository.job_begin(job.id)
    # 最初に認証されたところを正とする。
    @provider_repository.operational_all_with_params(:auth).each do |provider|
      user_data = provider.adapter.auth(username, password)
      break if user_data
    rescue => e
      @job_repository.job_errored(job.id)
      error!("認証時にエラーが発生しました。: #{e.message}")
    end

    unless user_data
      @job_repository.job_failed(job.id)
      error!('ユーザー名またはパスワードが違います。')
    end

    unless user_data[:name] == username
      @job_repository.job_errored(job.id)
      error!('認証には成功しましたが、ユーザー名が一致しません。')
    end

    @job_repository.job_succeeded(job.id)

    @user = create_or_upadte_user(user_data)
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end
    true
  end

  private def create_or_upadte_user(user_data)
    name = user_data[:name]
    display_name = user_data[:display_name] || user_data[:name]
    email = user_data[:email]
    user = @user_repository.by_name(name)
    if user.nil?
      @user_repository.create(name: name,
                              display_name: display_name,
                              email: email)
    elsif user.display_name != display_name || user.email != email
      @user_repository.update(user.id,
                              display_name: display_name,
                              email: email)
    else
      user
    end
  end
end
