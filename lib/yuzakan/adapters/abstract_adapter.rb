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
#     - :boolean, :string, :text, :intger, :float, :date, :time, :datetime,
#       :file
# - input: form inputのタイプ
#     - :text, :password, email, ...
#     - 省略時はtypeによって自動決定
# - required: 必須かどうか (デフォルト: fales)
# - placeholder: 入力時のプレースホルダー
# - input:
#     - :free, select, button
# - list: string等で自由入力ではなく一覧からの選択になる。
# - default: 新規作成時のデフォルト値
# - encrypted: 暗号化して保存するか (:string, :text, :fileのみ指定可能、
#              デフォルト: fales)

module Yuzakan
  module Adapters
    class Error < RuntimeError
    end

    class AbstractAdapter
      def self.label
        raise NotImplementedError
      end

      def self.selectable?
        false
      end

      def self.params
        @params || raise(NotImplementedError)
      end

      def self.params=(params)
        @params = params
        @name_param_map =
          params.map { |param| [param[:name].intern, param] }.to_h
      end

      def self.param_by_name(name)
        @name_param_map&.fetch(name)
      end

      def self.decrypt(data)
        decrypted_data = @params
          .select { |param| param[:encrypted] }
          .map do |param|
            name = param[:name].intern
            decrypt_opts =
              case param[:type]
              when :string, :text
                {}
              when :file
                {text: false}
              end
            decrypt = Decrypt.new(**decrypt_opts)
            result = decrypt.call(encrypted: data[name])
            raise Yuzakan::Adapters::Error, result.errors if result.failure?

            [name, result.data]
          end.to_h
        data.merge(decrypted_data)
      end

      def self.encrypt(data)
        encrypted_data = @params
          .select { |param| param[:encrypted] }
          .map do |param|
            name = param[:name].intern
            encrypt_opts =
              case param[:type]
              when :string
                {max: 4096}
              when :text
                {max: 0}
              when :file
                {max: 0, text: false}
              end
            encrypt = Encrypt.new(**encrypt_opts)
            result = encrypt.call(data: data[name])
            raise Yuzakan::Adapters::Error, result.errors if result.failure?

            [name, result.encrypted]
          end.to_h

        data.merge(encrypted_data)
      end

      def initialize(params)
        @params = self.class.decrypt(params)
      end

      def check
        raise NotImplementedError
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
