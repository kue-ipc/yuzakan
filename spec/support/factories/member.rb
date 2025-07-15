# frozen_string_literal: true

Factory.define(:member) do |f|
  f.association :user_with_nil
  f.association :group_with_nil
  f.timestamps
end
