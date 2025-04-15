# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Actions
    module I18n
      def self.included(action)
        action.include Deps["i18n"]
      end

      private def t(...) = i18n.t(...)
      private def l(...) = i18n.l(...)
    end
  end
end
