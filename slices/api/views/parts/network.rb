# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Network < API::Views::StructPart
        # value is a DB::Struct

        def to_h = super.merge({ip: value.ip.cidr})
      end
    end
  end
end
