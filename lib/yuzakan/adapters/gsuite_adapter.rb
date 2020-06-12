# frozen_string_literal: true

# G Suite Adapter
#
# CRUD
# create(username, attrs) -> user or nil [writable]
# read(username) -> user or nil [readable]
# update(username, attrs) -> user or nil [writeable]
# delete(username) -> user or nil [writable]
#
# auth(username, password) -> user or nil [authenticatable]
# change_password(username, password) -> user ro nil [password_changeable]
#
# lock(username) -> locked?(username) [lockable]
# unlock(username) -> locked?(username) [lockable]
# locked?(username) -> true or false [lockable]
#
# list -> usernames [readable]

module Yuzakan
  module Adapters
    class GsuiteAdapter < AbstractAdapter
      def self.label
        'G Suite'
      end

      def self.selectable?
        true
      end

      self.params = [
        {
          name: 'domain',
          label: 'G Suiteのドメイン名',
          description:
            'G Suiteでのドメイン名を指定します。',
          type: :string,
          required: true,
          placeholder: 'google.example.jp',
        }, {
          name: 'json_key',
          label: 'JSONキー',
          description:
            'G Suiteでのドメイン名を指定します。',
          type: :string,
          required: true,
          placeholder: 'google.example.jp',
        },
      ]

      def initialize(params)
        super
      end

      def check
        raise NotImplementedError
      end

      def create(_username, _attrs)
        raise NotImplementedError
      end

      def read(_username)
        raise NotImplementedError
      end

      def udpate(_username, _attrs)
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
