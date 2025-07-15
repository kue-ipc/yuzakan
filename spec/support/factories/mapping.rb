# frozen_string_literal: true

Factory.define(:mapping) do |f|
  f.association :attr
  f.association :service
  f.key { fake(:internet, :slug) }
  f.type "string"
  f.params({})
  f.timestamps
end
