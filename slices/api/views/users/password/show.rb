# frozen_string_literal: true

module API
  module Views
    module Users
      module Password
        class Show < API::View
          decorate :user_password
        end
      end
    end
  end
end
