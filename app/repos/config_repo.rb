# frozen_string_literal: true

module Yuzakan
  module Repos
    class ConfigRepo < Yuzakan::DB::Repo
      def created? = configs.exist?
      def current! = configs.one!

      def update_all(**)
        configs.command(:update, **UPDATE_TIMESTAMP).call(**)
      end
    end
  end
end
