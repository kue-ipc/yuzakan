module Admin
  module Views
    module Users
      class Index
        include Admin::View
        include Yuzakan::Helpers::PagyFrontend

        def routes_name
          :users
        end
      end
    end
  end
end
