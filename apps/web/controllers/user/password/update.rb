module Web
  module Controllers
    module User
      module Password
        class Update
          include Web::Action

          def call(params)
            pp params[:password]
          end
        end
      end
    end
  end
end