# frozen_string_literal: true

Factory.define(:managed_group) do |f|
  f.association :service
  f.association :group

  f.unmanageable false # default

  f.timestamps
end
