module Web
  module Controllers
    module Session
      class New
        include Web::Action

        def call(params)
        end

        private

        def authenicate!; end
      end
    end
  end
end
