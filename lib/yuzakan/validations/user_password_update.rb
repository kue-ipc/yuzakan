# frozen_string_literal: true

require 'hanami/validations'
require 'zxcvbn'

class UserPasswordUpdateValidaiton
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
