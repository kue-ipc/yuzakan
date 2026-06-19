# frozen_string_literal: true

require "yaml"

module Yuzakan
  module Adapters
    class Test < Yuzakan::Adapter
      version "0.1.0"
      hidden Hanami.env?(:production)
      group true
      primary_group true

      params do
        optional(:str).value(:str?, max_size?: 255)
        optional(:text).value(:str?)
        optional(:int).value(:int?)
        optional(:float).value(:float?)
        optional(:bool).value(:bool?)
        optional(:date).value(:date?)
        optional(:time).value(:time?)
        optional(:datetime).value(:date_time?)
        required(:required_str).value(:str?, max_size?: 255)
        optional(:filled_str).filled(:str?, max_size?: 255)
        optional(:pattern_str).value(:str?, format?: /\A[a-z]*\z/, max_size?: 255)
        optional(:fixed_str).value(:str?, eql?: "abc")
        optional(:default_str).value(:str?, max_size?: 255)
        optional(:encrypted_str).value(:str?, max_size?: 255)
        optional(:list).value(:str?, included_in?: %w[one two three])
      end

      set_default_param :default_str, "xyz"
      add_encrypted_key :encrypted_str

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

      def check = true

      def user_create(_username, _userade, password: nil) = nil
      def user_read(_username) = nil
      def user_update(_username, **_userdata) = nil
      def user_delete(_username) = nil
      def user_auth(_username, _password) = nil
      def user_change_password(_username, _password) = nil
      def user_generate_code(_username) = []
      def user_lock(_username) = nil
      def user_unlock(_username, password: nil) = nil
      def user_list = []
      def user_search(_query) = []

      def group_create(_groupname, _groupdata) = nil
      def group_read(_groupname) = nil
      def group_update(_groupname, **_groupdata) = nil
      def group_delete(_groupname) = nil
      def group_list = []
      def group_search(_query) = []

      def member_list(_groupname) = []
      def member_add(_groupname, _username) = nil
      def member_remove(_groupname, _username) = nil
    end
  end
end
