# frozen_string_literal: true

Factory.define(:user) do |f|
  f.association :members, count: 0
  f.association :groups, count: 1

  f.name { fake(:internet, :username) }
  f.label { fake(:name, :name) }
  f.email { fake(:internet, :email) }
  f.note { fake(:lorem, :paragraph) }

  f.attrs {} # default

  f.clearance_level 1 # default

  f.prohibited false # default

  f.deleted_at nil
  f.synced_at nil

  f.timestamps
end

Factory.define(user_without_label: :user) do |f|
  f.label "" # default
  f.email "" # default
  f.note "" # default
end

Factory.define(user_with_affiliation: :user) do |f|
  f.association :affiliation
end

Factory.define(user_with_groups: :user) do |f|
  f.association :group
  f.association :members, count: 2
end

Factory.define(guest: :user) do |f|
  f.clearance_level 0
end

# user with clearance level 1

Factory.define(observer: :user) do |f|
  f.clearance_level 2
end

Factory.define(operator: :user) do |f|
  f.clearance_level 3
end

Factory.define(administrator: :user) do |f|
  f.clearance_level 4
end

Factory.define(superuser: :user) do |f|
  f.clearance_level 5
end
