# frozen_string_literal: true

Factory.define(:group) do |f|
  f.name { fake(:internet, :username) }
  f.label { fake(:music, :rock_band, :name) }
  f.note { fake(:lorem, :paragraph) }
  f.basic false # default
  f.prohibited false # default
  f.deleted false # default
  f.deleted_at nil
  f.timestamps
end

Factory.define(group_with_nil: :group) do |f|
  f.label nil
  f.note nil
end
