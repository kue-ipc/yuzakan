# frozen_string_literal: true

module Local
  module Relations
    class LocalGroups < Local::DB::Relation
      schema :local_groups, infer: true do
        associations do
          has_many :local_users
          has_many :local_members
          has_many :local_users, as: :local_member_users,
            through: :local_members
        end
      end
    end
  end
end
