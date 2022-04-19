require_relative './set_attr'

module Api
  module Controllers
    module Attrs
      class Show
        include Api::Action
        include SetAttr

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.status = 200
          self.body =
            if current_level >= 2
              generate_json(@attr)
            else
              generate_json(convert_entity(@attr).except(:attr_mappings))
            end
        end
      end
    end
  end
end
