module Admin
  module Views
    module Users
      class New
        include Admin::View

        def form
          Form.new(:user, routes.users_path)
        end

        def submit_label
          '作成'
        end
      end
    end
  end
end
