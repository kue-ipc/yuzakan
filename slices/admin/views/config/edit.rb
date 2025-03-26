# frozen_string_literal: true

module Admin
  module Views
    module Config
      class Edit < Admin::View
        def form
          Form.new(
            :config,
            routes.path(:config),
            {config: config},
            method: :patch)
        end

        def password_scores
          # zxcvbn score
          # https://github.com/dropbox/zxcvbn
          {
            "0 (解読推定数 < 10^3) 非常に危険" => 0,
            "1 (解読推定数 < 10^6) とても危険" => 1,
            "2 (解読推定数 < 10^8) すこし危険" => 2,
            "3 (解読推定数 < 10^10) まぁまぁ安全" => 3,
            "4 (解読推定数 ≧ 10^10) とても安全" => 4,
          }
        end

        def generate_password_types
          [
            "alphanumeric",
            "ascii",
            "custom",
            "letter",
            "upper_letter",
            "lower_letter",
            "digit",
            "upper_hex",
            "lower_hex",
          ].to_h do |name|
            [t("enums.generate_password_types.#{name}"), name]
          end
        end
      end
    end
  end
end
