# frozen_string_literal: true

# パスワードの制限値について
# configで持たせるべきでは？
# 8以上 32以下
# zxcvbnも使用

require 'hanami/interactor'
require 'hanami/validations'

class ChangePassword
  include Hanami::Interactor

  # class Validation
  #   include Hanami::Validations
  #
  #   predicate :strong?, message: 'パスワードが弱すぎます。' do |current|
  #
  #   end
  #
  #   validations do
  #     required(:name) { filled? & min_size?(8) }
  #     required(:password_current) { filled? }
  #     required(:password) { filled? & min_size?(8) }.confirmation
  #   end
  #
  # end

  def initialize
  end

  def call()

  end

  def valide?
  end
end
