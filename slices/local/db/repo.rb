# frozen_string_literal: true

module Local
  module DB
    # FIXME: Yuzakan::DB::Repoから継承すると子クラスのclass.rootが:repoに
    # なってしまい、self.rootが正しくなくなる。
    # 対処として、Hanami::DB::Repoから継承する。
    #
    # class Repo < Yuzakan::DB::Repo
    # end
    class Repo < Hanami::DB::Repo
      private def generate_like_pattern(str, match: :partial)
        escaped = str.gsub("\\", "\\\\").gsub("_", "\\_").gsub("%", "\\%")
        case match
        in :partial
          "%#{escaped}%"
        in :prefix
          "#{escaped}%"
        in :suffix
          "%#{escaped}"
        in :exact
          escaped
        end
      end
    end
  end
end
