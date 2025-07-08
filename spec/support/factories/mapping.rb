# frozen_string_literal: true

Factory.define(:mapping) do |f|
  f.association :provider
  f.association :attr
  f.key Faker::Internet.slug
  f.conversion "->(value) { value }"
  f.timestamps
end
