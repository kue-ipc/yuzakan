# frozen_string_literal: true

Factory.define(:affiliation) do |f|
  f.name { fake(:internet, :username) }
  f.label { fake(:name, :name) }
  f.note { fake(:lorem, :paragraph) }

  f.timestamps
end

Factory.define(affiliation_without_params: :affiliation) do |f|
  f.label "" # default
  f.note "" # default
end
