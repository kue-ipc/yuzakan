module Mailers
  class UnlockUser
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
      'アカウントのロックを解除しました。'
    end

    def action
      'アカウントロック解除'
    end
  end
end
