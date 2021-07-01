module Yuzakan
  module Helpers
    module PagyFrontend
      include Pagy::Frontend

      def pagy_url_for(pagy, page, *_args, **_opts)
        routes.path(routes_name, pagy.vars[:page_param] => page,
                                 **pagy.vars[:params])
      end

      def pagy_nav(*args, **opts)
        _raw super
      end

      def pagy_info(*args, **opts)
        _raw super
      end
    end
  end
end
