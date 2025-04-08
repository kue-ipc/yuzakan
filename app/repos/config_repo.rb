# frozen_string_literal: true

module Yuzakan
  module Repos
    class ConfigRepo < Yuzakan::DB::Repo
      def get = configs.last
      alias current get

      def set(**)
        configs.changeset(:update, **).map(:touch).commit ||
          configs.changeset(:create, **).map(:add_timestamps).commit
      end
    end
  end
end
