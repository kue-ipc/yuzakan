# frozen_string_literal: true

class RoleRepository < Hanami::Repository
  associations do
    has_many :users
  end
end
