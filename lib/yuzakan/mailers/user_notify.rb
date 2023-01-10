# frozen_string_literal: true

module Mailers
  class UserNotify
    include Hanami::Mailer

    to      :recipient
    subject :subject

    private def recipient
      user.email
    end

    private def subject
      "#{config.title}【#{action}】"
    end
  end
end
