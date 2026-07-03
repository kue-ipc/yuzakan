# frozen_string_literal: true

Factory.define(:managed_user) do |f|
  f.association :service
  f.association :user

  f.timestamps
end
