# frozen_string_literal: true

module Mailers
  class ChangePassword
    include Hanami::Mailer

    to      :recipient
    subject :subject

    private def recipient
      user.email
    end

    private def subject
      "#{config.title}【#{action}】"
    end

    def desc
      'アカウントのパスワードを変更しました。'
    end

    def action
      'パスワード変更'
    end
  end
end
