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

require_relative 'error'

module Yuzakan
  module Adapters
    class ParamType
      @@type_inputs = {
        boolean: 'checkbox',
        string: 'text',
        text: 'textarea',
        integer: 'number',
      }

      attr_reader :name, :label, :description,
                  :type, :default, :fixed, :encrypted,
                  :input, :list, :required, :placeholder

      alias encrypted? encrypted
      alias fixed? fixed
      alias required? required

      def initialize(name:, label: nil, description: nil,
                     type: :string, default: nil, fixed: true, encrypted: false,
                     input: nil, list: nil, required: nil, placeholder: nil)
        @name = name.intern
        @label = label || name.to_s
        @description = description

        @type = type
        @default = default
        @fixed = fixed
        @encrypted = encrypted

        @input = input || @@type_inputs.fetch(type)
        @list = list&.map do |item|
          if item.is_a?(ParamType::ListItem)
            item
          else
            ParamType::ListItem.new(**item)
          end
        end
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

      def convert_value(value)
        return if value.nil?

        case type
        when :boolean
          if value.is_a?(String)
            ['1', 'yes', 'true'].include?(value.downcase)
          else
            nil | value
          end
        when :string, :text
          value.to_s
        when :integer
          value.to_i
        when :float
          value.to_f
        when :date
          if value.is_a?(Date) || value.is_a?(Time)
            value.to_date
          else
            Date.parse(value.to_s)
          end
        when :time
          if value.is_a?(Date) || value.is_a?(Time)
            value.to_time
          else
            Time.parse(value.to_s)
          end
        when :datetime
          if value.is_a?(Date) || value.is_a?(Time)
            value.to_datetime
          else
            DateTime.parse(value.to_s)
          end
        when :file
          value
        else
          raise "ParamType unknown type: #{type}"
        end
      end

      def dump_value(value)
        data = Marshal.dump(value)
        if encrypted?
          result = Encrypt.new.call(data: data)
          raise Yuzakan::Adapters::Error, result.errors if result.failure?

          data = result.encrypted
        end
        data
      end

      def load_value(data)
        if encrypted?
          result = Decrypt.new.call(encrypted: data)
          raise Yuzakan::Adapters::Error, result.errors if result.failure?

          data = result.data
        end
        Marshal.load(data)
      end

      # ListItem class
      class ListItem
        attr_reader :name, :label, :value, :deprecated

        alias deprecated? deprecated

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
