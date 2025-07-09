# frozen_string_literal: true

Factory.define(:mapping) do |f|
  f.association :service
  f.association :attr
  f.key { fake(:internet, :slug) }
  f.conversion "->(value) { value }"
  f.timestamps
end
