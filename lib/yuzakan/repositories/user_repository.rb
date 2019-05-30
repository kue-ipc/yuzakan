# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    belongs_to :role
  end

  def by_name(name)
    users.where(name: name).first
  end
end
