# frozen_string_literal: true

module Api
  module Controllers
    module System
      class Show
        include Api::Action

        security_level 0

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          # FIXME: サイトのURLを環境変数からとっている
          self.body = generate_json({
            url: ENV.fetch('SITE_URL', Web.routes.url(:root)),
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
