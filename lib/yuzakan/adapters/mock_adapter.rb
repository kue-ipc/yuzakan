require 'yaml'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class MockAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env == 'production'

      self.label = 'モック'

      self.params = [
        {
          name: :check,
          type: :boolean,
          default: true,
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

      def create(username, password = nil, **userdata)
        {**userdata, name: username}
      end

      def read(_username)
        nil
      end

      def udpate(username, **userdata)
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
