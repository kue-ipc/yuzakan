# auto_register: false
# frozen_string_literal: true

module API
  module Views
    module Parts
      class Pager < API::Views::Part
        def to_h
          {
            current_page: value.current_page,
            per_page: value.per_page,
            total: value.total,
            total_pages: value.total_pages,
            first_in_page: value.first_in_page,
            last_in_page: value.last_in_page,
          }
        end
      end
    end
  end
end
