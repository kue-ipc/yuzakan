# frozen_string_literal: true

module Yuzakan
  module Actions
    module About
      class Index < Yuzakan::Action
        security_level 0
        private def configurate!(_req, _res) = nil
        private def authenticate!(_req, _res) = nil

        def handle(req, res)
        end
      end
    end
  end
end
