# frozen_string_literal: true

require 'yaml'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class TestAdapter < AbstractAdapter
      def self.label
        'テスト'
      end

      def self.selectable?
        Hanami.env != 'production'
      end

      self.params = [
        {
          name: 'str1',
          label: '文字列',
          description:
            '文字列のパラメーターです。',
          type: :string,
          required: false,
          placeholder: '',
        },
        {
          name: 'str_enc',
          label: '暗号文字列',
          description:
            '文字列のパラメーターです。',
          type: :string,
          required: false,
          placeholder: 'テスト',
          encrypted: true,
        },
        {
          name: 'txt1',
          label: '長い文字列',
          description:
            '文字列のパラメーターです。',
          type: :text,
          required: false,
          placeholder: '',
          cols: 10,
          rows: 10,
        },
        {
          name: 'int1',
          label: '数値',
          description:
            '数値のパラメーターです。',
          type: :integer,
          required: false,
          placeholder: '',
        },
      ]

      def initialize(params)
        super
      end

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
