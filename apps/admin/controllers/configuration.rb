require_relative '../../web/controllers/configuration'

module Admin
  module Configuration
    include Web::Configuration

    private def allowed_networks
      current_config.admin_networks
    end
  end
end
