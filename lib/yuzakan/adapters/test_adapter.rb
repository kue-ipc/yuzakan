require 'yaml'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class TestAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env == 'production'

      self.label = 'テスト'

      self.params = [
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
        {
          name: :username,
          type: :string,
          default: 'user',
        },
        {
          name: :password,
          type: :string,
          default: 'password',
        },
        {
          name: :display_name,
          type: :string,
          default: 'ユーザー',
        },
        {
          name: :email,
          type: :string,
          default: 'user@example.jp',
        },
      ]

      def check
        true
      end

      def create(_username, _attrs, mappings = nil)
        raise NotImplementedError
      end

      def read(_username, mappings = nil)
        raise NotImplementedError
      end

      def udpate(_username, _attrs, mappings = nil)
        raise NotImplementedError
      end

      def delete(_username)
        raise NotImplementedError
      end

      def auth(_username, _password)
        raise NotImplementedError
      end

      def change_password(_username, _password)
        raise NotImplementedError
      end

      def lock(_username)
        raise NotImplementedError
      end

      def unlock(_username)
        raise NotImplementedError
      end

      def locked?(_username)
        raise NotImplementedError
      end

      def list
        raise NotImplementedError
      end
    end
  end
end
