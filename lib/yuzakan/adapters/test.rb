# frozen_string_literal: true

require "yaml"

module Yuzakan
  module Adapters
    class Test < Yuzakan::Adapter
      version "0.1.0"
      hidden Hanami.env?(:production)
      group true
      primary true

      json do
        optional(:str).value(:str?, max_size?: 255)
        optional(:text).value(:str?)
        optional(:int).value(:int?)
        optional(:float).value(:float?)
        optional(:bool).value(:bool?)
        optional(:date).value(:date?)
        optional(:time).value(:time?)
        optional(:datetime).value(:date_time?)
        required(:required_str).filled(:str?, max_size?: 255)
        optional(:pattern_str).value(:str?, format?: /\A[a-z]*\z/, max_size?: 255)
        optional(:fixed_str).value(:str?, eql?: "abc")
        optional(:default_str).value(:str?, max_size?: 255)
        optional(:list).value(:str?, included_in?: %w[one two three])
      end

      # self.params = [
      #   {
      #     name: :default,
      #   },
      #   {
      #     name: :str,
      #     label: "文字列",
      #     description: "詳細",
      #     placeholder: "プレースホルダー",
      #   },
      #   {
      #     name: :str_default,
      #     label: "デフォルト値",
      #     default: "デフォルト",
      #   },
      #   {
      #     name: :str_fixed,
      #     label: "固定値",
      #     default: "固定",
      #     fixed: true,
      #   },
      #   {
      #     name: :str_required,
      #     label: "必須文字列",
      #     required: true,
      #   },
      #   {
      #     name: :str_enc,
      #     label: "暗号文字列",
      #     encrypted: true,
      #   },
      #   {
      #     name: :text,
      #     label: "テキスト",
      #     type: :text,
      #   },
      #   {
      #     name: :int,
      #     label: "整数",
      #     type: :integer,
      #   },
      #   {
      #     name: :list,
      #     label: "リスト",
      #     default: "default",
      #     list: [
      #       {name: :default, label: "デフォルト", value: "default"},
      #       {name: :other, label: "その他", value: "other"},
      #       {name: :deprecated, label: "非推奨", value: "deprecated",
      #        deprecated: true,},
      #     ],
      #   },
      # ].tap(&Yuzakan::Utils::Object.method(:deep_freeze))

      def check
        true
      end

      def user_create(username, _password = nil, **userdata)
        {**userdata, name: username}
      end

      def user_read(_username)
        nil
      end

      def user_update(_username, **_userdata)
        nil
      end

      def user_delete(_username)
        nil
      end

      def user_auth(_username, _password)
        false
      end

      def user_change_password(_username, _password)
        nil
      end

      def user_generate_code(_username)
        []
      end

      def user_lock(_username)
        nil
      end

      def user_unlock(_username, _password = nil)
        nil
      end

      def user_list
        []
      end
    end
  end
end
