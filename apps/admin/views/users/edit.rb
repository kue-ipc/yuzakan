module Admin
  module Views
    module Users
      class Edit
        include Admin::View

        def form
          Form.new(:user, routes.user_path(id: user.id), {user: user}, method: :patch)
        end

        def submit_label
          '更新'
        end
      end
    end
  end
end
