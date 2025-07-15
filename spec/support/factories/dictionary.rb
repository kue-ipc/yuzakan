# frozen_string_literal: true

Factory.define(:dictionary) do |f|
  f.name { fake(:internet, :username) }
  f.label { fake(:japanese_media, :naruto, :village) }
  f.description { fake(:lorem, :sentence) }
  f.timestamps
end

Factory.define(dictionary_without_label: :dictionary) do |f|
  f.label "" # default
  f.description "" # default
end
