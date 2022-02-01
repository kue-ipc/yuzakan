module Api
  module Views
    module Session
      class Destroy
        include Api::View

        def render
          raw JSON.generate(result)
        end
      end
    end
  end
end
