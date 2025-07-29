# frozen_string_literal: true

Factory.define(:group) do |f|
  f.association :affiliation
  f.name { fake(:internet, :username) }
  f.label { fake(:music, :rock_band, :name) }
  f.note { fake(:lorem, :paragraph) }
  f.basic false # default
  f.prohibited false # default
  f.deleted false # default
  f.deleted_at nil
  f.timestamps
end

Factory.define(basic_group: :group) do |f|
  f.basic true # default
end

Factory.define(group_without_label: :group) do |f|
  f.label ""
  f.note ""
end
