# frozen_string_literal: true

module Admin
  module Views
    module Config
      class Show < Admin::View
        expose :password_scores do
          # zxcvbn score
          # https://github.com/dropbox/zxcvbn
          [0, 1, 2, 3, 4]
        end

        expose :generate_password_types do
          %w[
            ascii
            alphanumeric
            letter
            upper_letter
            lower_letter
            digit
            upper_hex
            lower_hex
            custom
          ]
        end
      end
    end
  end
end
