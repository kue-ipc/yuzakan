# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Network < API::Views::Part
        # value is a DB::Struct

        def to_h
          hash = value.to_h
          hash.except(:id, :created_at, :updated_at).merge({ip: hash[:ip].cidr})
        end

        def to_json(...) = helpers.params_to_json(to_h, ...)

        def ip_to_s(ip)

        end
      end
    end
  end
end
