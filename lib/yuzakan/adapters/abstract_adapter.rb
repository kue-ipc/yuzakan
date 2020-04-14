# frozen_string_literal: true

# adapter
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

# params is Hash Array
# - name: 識別名
# - label: 表示名
# - description: 説明
# - type: 型
#     - :string, :intger, :boolean, :text, :file
# - input: form inputのタイプ
#     - :text, :password, email, ...
# - required: 必須かどうか
# - placeholder: 入力時のプレースホルダー
# - input:
#     - :free, select, button
# - list: string等で自由入６ではなく一覧からの選択になる。
# - default: 新規作成時のデフォルト値


module Yuzakan
  module Adapters
    class AbstractAdapter
      def self.label
        raise NotImplementedError
      end

      def self.selectable?
        false
      end

      def self.params
        @params ||= []
      end

      def self.param_type(name)
        @param_types ||= params
          .map { |param| [param[:name].intern, param[:type]] }
          .to_h
        @param_types[name]
      end

      def initialize(params)
        @params = params
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
