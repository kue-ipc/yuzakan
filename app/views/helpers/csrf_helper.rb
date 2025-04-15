# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module CSRFHelper
        def csrf_meta_tag
          escape_join([
            csrf_param_meta_tag,
            csrf_token_meta_tag,
          ])
        end

        def csrf_param_meta_tag
          tag.meta(name: "csrf-param", content: csrf_param)
        end

        def csrf_token_meta_tag
          tag.meta(name: "csrf-token", content: csrf_token)
        end

        def csrf
          {csrf_param => csrf_token}
        end

        def csrf_param
          Yuzakan::Action::CSRF_TOKEN
        end

        def crsf_hidden_tag
          tag.input(name: csrf_param, type: "name", value: csrf_token)
        end
      end
    end
  end
end
