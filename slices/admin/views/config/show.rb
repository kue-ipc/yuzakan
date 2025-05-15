# frozen_string_literal: true

module Admin
  module Views
    module Config
      class Show < Admin::View
        expose :password_scores, as: :list do
          # zxcvbn score
          # https://github.com/dropbox/zxcvbn
          List.new(scope: "enums.password_scores",
            list: [0, 1, 2, 3, 4])
        end

        expose :generate_password_types, as: :list do
          List.new(scope: "enums.generate_password_types",
            list: Yuzakan::Operations::GeneratePassword::TYPES)
        end
      end
    end
  end
end
