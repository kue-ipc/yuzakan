# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      include AlertHelper
      include BsHelper
      include CSRFHelper
      include GridHelper
      include IconHelper
      include HtmlHelper
      # include ErrorHelper
      # include EscapeHelper
      # include ImportmapHelper
      # include PatternHelper
    end
  end
end
