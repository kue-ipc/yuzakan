module Mailers
  class ResetPassword
    include Hanami::Mailer

    to      :recipient
    subject :subject

    private def recipient
      user.email
    end

    private def subject
      "#{config.title}【#{action}】"
    end

    def verb
      'パスワードをリセットしました。'
    end

    def action
      'パスワードリセット'
    end
  end
end
