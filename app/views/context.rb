# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    class Context < Hanami::View::Context
      include Deps[
        i18n_t: "i18n.t",
        i18n_l: "i18n.l"
      ]

      def t(...)
        i18n_t.call(...)
      end

      def l(...)
        i18n_l.call(...)
      end
    end
  end
end
