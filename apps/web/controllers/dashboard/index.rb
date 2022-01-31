module Web
  module Controllers
    module Dashboard
      class Index
        include Web::Action

        def initialize(*args, **opts, &block)
          pp({args: args, opts: opts, block: block})
          super
        end

        def call(params)
        end
      end
    end
  end
end
