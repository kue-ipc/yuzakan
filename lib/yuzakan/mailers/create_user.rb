module Mailers
  class CreateUser
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
      'アカウントを作成しました。'
    end

    def action
      'アカウント作成'
    end
  end
end
