# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Actions
    module Flash
      private def add_flash(_request, response, level, msg, now: true)
        if now
          response.flash.now[level] ||= []
          response.flash.now[level] << msg
        else
          # keep only one message
          response.flash[level] = [msg]
        end
      end
    end
  end
end
