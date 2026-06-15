# auto_register: false
# frozen_string_literal: true

module API
  module Views
    class StructPart < API::Views::Part
      # value is a DB::Sturct

      def to_h(...) = super.except(:id, :created_at, :updated_at)
    end
  end
end
