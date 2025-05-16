# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        class BsBuilder
          module List
            DT_COL_CLASS = %w[
              col-sm-6
              col-md-4
              col-lg-3
              col-xl-2
              ].freeze

            DD_COL_CLASS = %w[
              col-sm-6
              col-md-8
              col-lg-9
              col-xl-10
              ].freeze

            DD_NEXT_COL_CLASS = %w[
              offset-sm-6 col-sm-6
              offset-md-4 col-md-8
              offset-lg-3 col-lg-9
              offset-xl-2 col-xl-10
              ].freeze

            def horizontal_dl(*, **opts, &)
              dl_opts = {**opts, class: [opts[:class], "row"]}
              dl(*, **dl_opts, &)
            end

            def horizontal_dt(*, truncate: false, **opts, &)
              dt_class = [opts[:class], DT_COL_CLASS, {"text-truncate" => truncate}]
              dd_opts = {**opts, class: dt_class}
              dt(*, **dd_opts, &)
            end

            def horizontal_dd(*list, **opts, &)
              dd_opts = {**opts, class: [opts[:class], DD_COL_CLASS]}
              first_dd = dd(list.first, **dd_opts, &)
              if list.size <= 1
                first_dd
              else
                dd_next_opts = {**opts, class: [opts[:class], DD_NEXT_COL_CLASS]}
                dd_list = [first_dd] +
                  list.drop(1).map { |item| dd(item, **dd_next_opts) }
                EscapeHelper.escape_join(dd_list)
              end
            end
          end
        end
      end
    end
  end
end
