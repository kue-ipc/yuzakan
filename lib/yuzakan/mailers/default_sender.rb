# frozen_string_literal: true

module Mailers
  module DefaultSender
    def self.included(mailer)
      mailer.class_eval do
        from ENV.fetch("SMTP_FROM", "no-reply")
      end
    end
  end
end
