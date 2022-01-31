require_relative '../../web/controllers/authorization'

module Api
  module Authorization
    include Web::Authorization

    private def allowed_networks
      current_config.admin_networks
    end
  end
end
