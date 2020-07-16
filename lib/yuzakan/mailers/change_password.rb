module Mailers
  class ChangePassword
    include Hanami::Mailer

    to      :recipient
    subject :subject

    private def recipient
      user.email
    end

    private def subject
      "#{config.title}【パスワード変更】"
    end
  end
end
