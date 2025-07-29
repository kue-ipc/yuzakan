# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Config < Yuzakan::Views::Parts::Config
        # value is a DB::Sturct

        def to_h = value.to_h.except(:id, :created_at, :updated_at)
        def to_json(...) = helpers.params_to_json(to_h, ...)
      end
    end
  end
end
