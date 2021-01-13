require_relative 'helpers/alerter'
require_relative 'helpers/error'
require_relative 'helpers/escaper'
require_relative 'helpers/grid'
require_relative 'helpers/menu'

module Yuzakan
  module Helpers
    include Yuzakan::Helpers::Alerter
    include Yuzakan::Helpers::Error
    include Yuzakan::Helpers::Escaper
    include Yuzakan::Helpers::Grid
    include Yuzakan::Helpers::Menu
  end
end
