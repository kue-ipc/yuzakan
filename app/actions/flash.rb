# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Actions
    module Flash
      private def add_flash(res, level, msg, now: true)
        if now
          res.flash.now[level] ||= []
          res.flash.now[level] << msg
        else
          # keep only one message
          res.flash[level] = [msg]
        end
      end
    end
  end
end
