# frozen_string_literal: true

module Yuzakan
  module Repos
    class ConfigRepo < Yuzakan::DB::Repo
      def current = configs.last

      def set(**)
        configs.changeset(:create, **).map(:add_timestamps).commit
      end
    end
  end
end
