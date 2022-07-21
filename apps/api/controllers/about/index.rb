module Api
  module Controllers
    module About
      class Index
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          self.body = generate_json({
            url: Web.routes.url(:root),
            config: {
              title: current_config&.title,
              contact_name: current_config&.contact_name,
              contact_email: current_config&.contact_email,
              contact_phone: current_config&.contact_phone,
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
