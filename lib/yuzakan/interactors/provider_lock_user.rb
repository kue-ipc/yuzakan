# frozen_string_literal: true

require "hanami/validations"
require_relative "../provider_interactor"

class ProviderLockUser
  include Yuzakan::ProviderInteractor

  class Validator
    include Hanami::Validations
    predicates NamePredicates
    messages :i18n

    validations do
      required(:username).filled(:str?, :name?, max_size?: 255)
      optional(:providers).each(:str?, :name?, max_size?: 255)
    end
  end

  def call(params)
    username = params[:username]

    call_providers(params[:providers], operation: :user_lock) do |provider|
      provider.user_lock(username)
    end
  end
end
