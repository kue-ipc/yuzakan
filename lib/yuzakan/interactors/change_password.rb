# frozen_string_literal: true

# パスワードの制限値について
# configで持たせるべきでは？
# 8以上 32以下
# zxcvbnも使用

require 'hanami/interactor'
require 'hanami/validations'
require 'zxcvbn'

class ChangePassword
  include Hanami::Interactor

  def initialize(
    providers: ProviderRepository.new.operational_all(:change_password)
  )
    @providers = providers
  end

  def call(username:, password:)
    @providers.each.all? do |provider|
      provider.adapter.new(provider.params).change_password(username, password)
    end
  end
end
