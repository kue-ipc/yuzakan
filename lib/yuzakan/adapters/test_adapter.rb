require 'yaml'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class TestAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env == 'production'

      self.name = 'test'
      self.label = 'テスト'
      self.version = '0.0.1'
      self.params = [
        {
          name: :default,
        },
        {
          name: :str,
          label: '文字列',
          description: '詳細',
          placeholder: 'プレースホルダー',
        },
        {
          name: :str_default,
          label: 'デフォルト値',
          default: 'デフォルト',
        },
        {
          name: :str_fixed,
          label: '固定値',
          default: '固定',
          fixed: true,
        },
        {
          name: :str_required,
          label: '必須文字列',
          required: true,
        },
        {
          name: :str_enc,
          label: '暗号文字列',
          encrypted: true,
        },
        {
          name: :text,
          label: 'テキスト',
          type: :text,
        },
        {
          name: :int,
          label: '整数',
          type: :integer,
        },
        {
          name: :list,
          label: 'リスト',
          default: 'default',
          list: [
            {name: :default, label: 'デフォルト', value: 'default'},
            {name: :other, label: 'その他', value: 'other'},
            {name: :deprecated, label: '非推奨', value: 'deprecated', deprecated: true},
          ],
        },
      ]

      def check
        true
      end

      def create(username, _password = nil, **userdata)
        {**userdata, name: username}
      end

      def read(_username)
        nil
      end

      def udpate(_username, **_userdata)
        nil
      end

      def delete(_username)
        nil
      end

      def auth(_username, _password)
        false
      end

      def change_password(_username, _password)
        nil
      end

      def generate_code(_username)
        []
      end

      def lock(_username)
        nil
      end

      def unlock(_username, _password = nil)
        nil
      end

      def list
        []
      end
    end
  end
end
