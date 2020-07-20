module Mailers
  class DestroyUser
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
      'アカウントを削除しました。'
    end

    def action
      'アカウント削除'
    end
  end
end
