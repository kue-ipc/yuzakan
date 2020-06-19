# frozen_string_literal: true

class ActivityRepository < Hanami::Repository
  associations do
    belongs_to :user
  end
end
