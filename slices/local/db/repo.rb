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
    end
  end
end
