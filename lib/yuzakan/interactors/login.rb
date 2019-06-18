# frozen_string_literal: true

require 'hanami/interactor'
require 'hanami/validations'

class Login
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

  def initialize
    @repostiory = UserRepository.new
  end

  def call(params)
    @user = @repostiory.auth(
      params[:username],
      params[:password],
    )
    unless @user
      error('ユーザー名またはパスワードが違います。')
    end
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    error(params: validation.messages) if validation.failure?
    validation.success?
  end
end
