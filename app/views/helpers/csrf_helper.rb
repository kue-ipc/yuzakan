# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module CSRFHelper
        def csrf_param_meta_tag
          tag.meta(name: "csrf-param", content: Yuzakan::Action::CSRF_TOKEN)
        end

        def csrf_token_meta_tag
          tag.meta(name: "csrf-token", content: csrf_token)
        end
      end
    end
  end
end
