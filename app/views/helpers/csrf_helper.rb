# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module CSRFHelper
        CSRF_TOKEN = Yuzakan::Action::CSRF_TOKEN
        def csrf_token
          content.session[CSRF_TOKEN]
        end

        def csrf_meta_tags
          tag.meta(name: "csrf-param", content: CSRF_TOKEN) +
            tag.meta(name: "csrf-token", content: csrf_token)
        end
      end
    end
  end
end
