# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module GridHelper
        def col_card
          %w[
            col-sm-6
            col-lg-4
            col-xl-3
          ]
        end

        def col_name
          %w[
            col-sm-6
            col-md-4
            col-lg-3
            col-xl-2
          ]
        end

        def col_value
          %w[
            col-sm-6
            col-md-8
            col-lg-9
            col-xl-10
          ]
        end
      end
    end
  end
end
