module Admin
  module Views
    module Config
      class Edit
        include Admin::View

        def form
          Form.new(
            :config,
            routes.path(:config),
            {config: current_config},
            method: :patch)
        end

        def password_scores
          # zxcvbn score
          # https://github.com/dropbox/zxcvbn
          {
            '0 (解読推定数 < 10^3) 非常に危険' => 0,
            '1 (解読推定数 < 10^6) とても危険' => 1,
            '2 (解読推定数 < 10^8) すこし危険' => 2,
            '3 (解読推定数 < 10^10) まぁまぁ安全' => 3,
            '4 (解読推定数 ≧ 10^10) とても安全' => 4,
          }
        end
      end
    end
  end
end
