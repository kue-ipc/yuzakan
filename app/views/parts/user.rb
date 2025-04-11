# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class User < Yuzakan::Views::Part
        def path
          context.routes.path(:user)
        end

        def title
          value.label_name
        end

        def link_tag(**, &)
          if block_given?
            helpers.link_to(path, title:, **, &)
          else
            helpers.link_to(title, path, title:, **)
          end
        end
      end
    end
  end
end
