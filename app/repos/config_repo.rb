# frozen_string_literal: true

module Yuzakan
  module Repos
    class ConfigRepo < Yuzakan::DB::Repo
      def get = configs.last
      alias current get

      def set(**)
        configs.command(:update, **UPDATE_TIMESTAMP).call(**) ||
          configs.command(:create, **CREATE_TIMESTAMP).call(**)
      end
    end
  end
end
