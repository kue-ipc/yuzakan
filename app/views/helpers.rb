# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      include AlertHelper
      include BsHelper
      include BsIconHelper
      include CSRFHelper
      include GridHelper
      include MarkdownHelper
      include TitleHelper
    end
  end
end
