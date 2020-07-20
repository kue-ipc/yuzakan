# frozen_string_literal: true

module Mailers
  class GenerateCode
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
      'バックアップコードを生成しました。'
    end

    def action
      'バックアップコード生成'
    end
  end
end
