# frozen_string_literal: true

Factory.define(:group) do |f|
  f.association :affiliation
  # f.association :users, count: 2
  # f.association :memebr_users, count: 2
  # f.association :members, count: 2
  # f.association :managings, count: 2
  f.association :services, count: 2

  f.name { fake(:internet, :username) }
  f.label { fake(:music, :rock_band, :name) }
  f.note { fake(:lorem, :paragraph) }

  f.attrs({}) # default

  f.basic false # default
  f.prohibited false # default

  f.deleted_at nil
  f.synced_at nil

  f.timestamps
end

Factory.define(basic_group: :group) do |f|
  f.basic true # default
end

Factory.define(group_without_label: :group) do |f|
  f.label ""
  f.note ""
end
