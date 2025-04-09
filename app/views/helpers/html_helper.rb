# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module HtmlHelper
        def html_join(*list)
          list.sum("") { |html| escape_html(html) }.html_safe
        end
      end
    end
  end
end
