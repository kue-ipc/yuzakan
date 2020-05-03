# frozen_string_literal: true

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class TestAdapter < AbstractAdapter
      def self.label
        'テスト用アダプター'
      end

      def self.selectable?
        Hanami.env != 'production'
      end

      def self.params
        @params ||= [
          {
            name: 'string_param',
            label: '文字列',
            description:
              '文字列のパラメーターです。',
            type: :string,
            required: true,
            placeholder: '',
          }
        ]
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
