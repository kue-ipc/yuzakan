# frozen_string_literal: true

module API
  module Views
    module Config
      class Show < API::View
        # NOTE: :configを指定するだけでは、設定のconfigを持ってきてしまうため、
        #   ブロックで設定する必要がある。
        expose :config do |config:|
          config
        end
      end
    end
  end
end
