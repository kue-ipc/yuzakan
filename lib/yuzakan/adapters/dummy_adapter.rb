# frozen_string_literal: true

# adapter
#
# CRUD
# create(name, attrs) -> true/false
# read(name) -> attrs
# update(name, attrs) -> true/false
# delete(name) -> true/false
#
# auth(name, pass)
# change_passwd(user, pass)
#

module Yuzakan
  module Adapters
    class DummyAdapter
      NAME = 'ダミー'

      PARAMS = []

      def initialize(params)
        @params = params
      end

      def create(name, attrs)
        raise NotImplementedError
      end

      def read(name)
        raise NotImplementedError
      end

      def udpate(name, attrs)
        raise NotImplementedError
      end

      def delete(name)
        raise NotImplementedError
      end

      def auth(name, pass)
        raise NotImplementedError
      end

      def change_passwd(name, pass)
        raise NotImplementedError
      end
    end
  end
end
