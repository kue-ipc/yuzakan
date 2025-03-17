# frozen_string_literal: true

require "json"

module Admin
  module Views
    module Groups
      class Export < Admin::View
        format :jsonl

        def render
          text = GroupRepository.new.all.map do |group|
            {
              name: group.name,
              display_name: group.display_name,
              note: group.note,
              basic: group.basic,
              prohibited: group.prohibited,
              deleted: group.deleted,
              deleted_at: group.deleted_at,
            }
          end.map { |data| JSON.generate(data) }.join("\n")
          raw text
        end
      end
    end
  end
end
