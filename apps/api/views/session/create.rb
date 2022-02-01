module Api
  module Views
    module Session
      class Create
        include Api::View

        def render
          raw JSON.generate(result)
        end
      end
    end
  end
end
