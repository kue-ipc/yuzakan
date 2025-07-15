# frozen_string_literal: true

Factory.define(:term) do |f|
  f.association :dictionary
  f.term { fake(:lorem, :word) }
  f.description { fake(:japanese_media, :naruto, :character) }
  f.timestamps
end
