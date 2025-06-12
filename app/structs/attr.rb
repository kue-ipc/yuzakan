# frozen_string_literal: true

module Yuzakan
  module Structs
    class Attr < Yuzakan::DB::Struct
      TYPES = %w[
        boolean
        string
        integer
        float
        date
        time
        datetime
      ].freeze

      def label_name
        if display_name
          "#{display_name} (#{name})"
        else
          name
        end
      end

      def label
        display_name || name
      end

      def mappings
        mappings
      end

      def mapping_by_provider_id(provider_id)
        mappings.find { |mapping| mapping.provider_id == provider_id }
      end
    end
  end
end
