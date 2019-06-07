# frozen_string_literal: true

# adapter
#
# CRUD
# create(username, attrs) -> user or nil
# read(username) -> attrs
# update(username, attrs) -> true/false
# delete(username) -> true/false
#
# auth(username, password)
# change_passwd(user, password)
#

module Yuzakan
  module Adapters
    class BaseAdapter
      def self.name
        raise NotImplementedError
      end

      def self.usable?
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
    end
  end
end
