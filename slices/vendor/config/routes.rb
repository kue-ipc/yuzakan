# frozen_string_literal: true

module Vendor
  class Routes < Hanami::Routes
    root to: ->(_env) { [200, {}, [""]] }
  end
end
