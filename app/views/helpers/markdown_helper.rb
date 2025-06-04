# auto_register: false
# frozen_string_literal: true

require "kramdown"
require "kramdown-parser-gfm"

module Yuzakan
  module Views
    module Helpers
      module MarkdownHelper
        def markdown(str, **)
          Kramdown::Document.new(str, input: "GFM", hard_wrap: false, **).to_html.html_safe
        end
      end
    end
  end
end
