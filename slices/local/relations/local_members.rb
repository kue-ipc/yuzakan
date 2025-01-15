# frozen_string_literal: true

module Local
  module Relations
    class LocalMembers < Local::DB::Relation
      schema :local_members, infer: true do
        associations do
          belongs_to :local_user
          belongs_to :local_group
        end
      end
    end
  end
end
