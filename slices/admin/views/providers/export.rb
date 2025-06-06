# frozen_string_literal: true

require "json"

module Admin
  module Views
    module Providers
      class Export < Admin::View
        format :jsonl

        def render
          # TODO: localプロバイダーのみ対応のため、決め打ちで処理する。
          # プロバイダー毎にエクスポートできるようになるべき？
          text = LocalUserRepository.new.all.map { |user|
            {
              username: user.username,
              hashed_password: user.hashed_password,
              display_name: user.display_name,
              email: user.email,
              locked: user.locked,
            }
          }.map { |data| JSON.generate(data) }.join("\n")
          raw text
        end
      end
    end
  end
end
