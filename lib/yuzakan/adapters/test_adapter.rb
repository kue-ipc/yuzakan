require 'yaml'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class TestAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env == 'production'
      self.label = 'テスト'
      self.params = [
        {
          name: :str,
          label: '文字列',
          description: '文字列の詳細',
          type: :string,
          default: 'デフォルト文字列',
          required: true,
          placeholder: 'プレースホルダー',
        },
        {
          name: :str_enc,
          label: '暗号文字列',
          description:
            '文字列のパラメーターです。',
          type: :string,
          required: false,
          placeholder: 'テスト',
          encrypted: true,
        },
        {
          name: :txt1,
          label: '長い文字列',
          description:
            '文字列のパラメーターです。',
          type: :text,
          required: false,
          placeholder: '',
        },
        {
          name: :int1,
          label: '数値',
          description:
            '数値のパラメーターです。',
          type: :integer,
          required: false,
          placeholder: '',
        },
        {
          name: :str1,
          label: '文字列',
          description:
            '文字列のパラメーターです。',
          type: :string,
          required: false,
          placeholder: '',
        },
        {
          name: :str_enc,
          label: '暗号文字列',
          description:
            '文字列のパラメーターです。',
          type: :string,
          required: false,
          placeholder: 'テスト',
          encrypted: true,
        },
        {
          name: :txt1,
          label: '長い文字列',
          description:
            '文字列のパラメーターです。',
          type: :text,
          required: false,
          placeholder: '',
        },
        {
          name: :int1,
          label: '数値',
          description:
            '数値のパラメーターです。',
          type: :integer,
          required: false,
          placeholder: '',
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
