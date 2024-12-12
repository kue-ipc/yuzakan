# frozen_string_literal: true

module Api
  module Actions
    module System
      class Show < API::Action
        security_level 0

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          self.body = generate_json({
            url: Web.routes.url(:root),
            title: current_config&.title,
            domain: current_config&.domain,
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
