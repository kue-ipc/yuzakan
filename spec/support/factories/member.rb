# frozen_string_literal: true

Factory.define(:member) do |f|
  f.association :user
  f.association :group
  f.timestamps
end
