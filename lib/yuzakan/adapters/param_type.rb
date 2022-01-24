# ParamType class
#
# params is Hash Array
# - name: 識別名
# - label: 表示名
# - description: 説明
#
# - type: 保存型
#     - :boolean, :string, :text, :intger, :float, :date, :time, :datetime, :file
# - default: 新規作成時のデフォルト値
# - fixed: 固定値か？ (tureの場合は常にdefaltの値になる、デフォルト: false)
# - encrypted: 暗号化して保存するか？ (:string, :text, :fileのみ指定可能、デフォルト: fales)
#
# - input: form inputのタイプ
#     - :text, :password, email, ...
#     - 省略時はtypeによって自動決定
# - list: string等で自由入力ではなく一覧からの選択
# - required: 必須かどうか (デフォルト: fales)
# - placeholder: 入力時のプレースホルダー

require 'date'
require 'time'

module Yuzakan
  module Adapters
    class ParamType
      class Error; end

      TYPE_INPUTS = {
        boolean: 'checkbox',
        string: 'text',
        text: 'textarea',
        integer: 'number',
      }.freeze

      attr_reader :name, :label, :description,
                  :type, :default, :fixed, :encrypted,
                  :input, :list, :required, :placeholder

      alias encrypted? encrypted

      def initialize(name:, label: nil, description: nil,
                     type: :string, default: nil, fixed: true, encrypted: false,
                     input: nil, list: nil, required: nil, placeholder: nil)
        @name = name.intern
        @label = label || name.to_s
        @description = description

        @type = type
        @default = default

        @list = list&.map do |item|
          if item.is_a?(ParamType::ListItem)
            item
          else
            ParamType::ListItem.new(**item)
          end
        end
        @encrypted = encrypted

        @input = input || TYPE_INPUTS.fetch(type)

        @required =
          if required.nil?
            default.nil?
          else
            required
          end

        @placeholder = placeholder || default
      end

      def to_json(...)
        {
          name: name,
          label: label,
          description: description,

          type: type,
          default: default,
          list: list,
          encrypted: encrypted,

          input: input,
          placeholder: placeholder,
          required: required,
        }.to_json(...)
      end

      def convert_value(str)
        return if str.nil?

        case type
        when :boolean
          ['1', 'yes', 'true'].include?(str.downcase)
        when :string, :text
          str
        when :integer
          str.to_i
        when :float
          str.to_f
        when :date
          Date.parse(str)
        when :time
          Time.parse(str)
        when :datetime
          DateTime.parse(str)
        # when :file
        #   str
        else
          raise "ParamType unknown type: #{type}"
        end
      end

      def dump_value(value)
        data = Marshal.dump(value)
        if encrypted
          result = Encrypt.new.call(data: data)
          raise Yuzakan::Adapters::ParamType::Error, result.errors if result.failure?

          data = result.encrypted
        end
        data
      end

      def load_value(data)
        if encrypted
          result = Decrypt.new.call(encrypted: data)
          raise Yuzakan::Adapters::ParamType::Error, result.errors if result.failure?

          data = result.data
        end
        Marshal.load(data)
      end

      # ListItem class
      class ListItem
        attr_reader :name, :label, :value, :deprecated

        def initialize(name:, value:, label: nil, deprecated: false)
          @name = name.intern
          @label = label || name.to_s
          @value = value
          @deprecated = deprecated
        end

        def to_json(...)
          {name: name, label: label, value: value, deprecated: deprecated}.to_json(...)
        end
      end
    end
  end
end
