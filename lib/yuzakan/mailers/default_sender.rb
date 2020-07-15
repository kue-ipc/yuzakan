module Mailers
  module DefaultSender
    def self.include(mailer)
      mailer.class_eval do
        from ENV.fetch('SMTP_FROM', 'no-reply')
      end
    end
  end
end
