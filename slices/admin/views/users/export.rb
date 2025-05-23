# frozen_string_literal: true

require "json"

module Admin
  module Views
    module Users
      class Export < Admin::View
        format :jsonl

        def render
          text = UserRepository.new.all.map { |user|
            {
              name: user.name,
              display_name: user.display_name,
              email: user.email,
              note: user.note,
              clearance_level: user.clearance_level,
              prohibited: user.prohibited,
              deleted: user.deleted,
              deleted_at: user.deleted_at,
            }
          }.map { |data| JSON.generate(data) }.join("\n")
          raw text
        end
      end
    end
  end
end
