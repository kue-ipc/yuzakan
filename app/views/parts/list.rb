# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class List < Yuzakan::Views::Part
        def values
          value.list.map do |name|
            [self[name], name]
          end
        end

        def [](name)
          context.t(name, scope: value.scope)
        end

        def size
          value.list.size
        end
      end
    end
  end
end
