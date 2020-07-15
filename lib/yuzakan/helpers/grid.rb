# frozen_string_literal: true

module Yuzakan
  module Helpers
    module Grid
      private def col_card
        %w[
          col-sm-6
          col-lg-4
          col-xl-3
        ]
      end

      private def col_name
        %w[
          col-sm-6
          col-md-4
          col-lg-3
          col-xl-2
        ]
      end

      private def col_value
        %w[
          col-sm-6
          col-md-8
          col-lg-6
          col-xl-4
        ]
      end
    end
  end
end
