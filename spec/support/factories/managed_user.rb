# frozen_string_literal: true

Factory.define(:managed_user) do |f|
  f.association :service
  f.association :user

  f.unmanageable false # default
  f.locked false # default
  f.mfa false # default

  f.timestamps
end
