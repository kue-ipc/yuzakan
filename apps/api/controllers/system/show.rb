module Api
  module Controllers
    module System
      class Show
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = generate_json({
            url: Web.routes.url(:root),
            title: current_config&.title,
            contact: {
              name: current_config&.contact_name,
              email: current_config&.contact_email,
              phone: current_config&.contact_phone,
            },
            app: {
              name: Yuzakan.name,
              version: Yuzakan.version,
              license: Yuzakan.license,
            },
          })
        end

        def configurate!
        end
      end
    end
  end
end
