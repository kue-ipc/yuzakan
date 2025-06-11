# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Config < Yuzakan::Views::Parts::Config
        def to_h = value.to_h.except(:id)
        def to_json(...) = helpers.params_to_json(to_h)
      end
    end
  end
end
