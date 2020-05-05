module Legacy
  module Controllers
    module About
      class Index
        include Legacy::Action

        def call(params)
        end

        def authenticate!; end
      end
    end
  end
end
