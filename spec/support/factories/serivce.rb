# frozen_string_literal: true

Factory.define(:service) do |f|
  f.name { fake(:internet, :username) }
  f.label { fake(:app, :name) }
  f.description { fake(:lorem, :paragraph) }
  f.order 1
  f.adapter "dummy"
  f.params({})
  f.readable false # default
  f.writable false # default
  f.authenticatable false # default
  f.password_changeable false # default
  f.lockable false # default
  f.group false # default
  f.individual_password false # default
  f.self_management false # default
  f.timestamps
end

Factory.define(service_without_label: :service) do |f|
  f.label "" # default
  f.description "" # default
end

Factory.define(mock_service: :service) do |f|
  f.name "mock"
  f.adapter "mock"
  f.readable true
  f.writable true
  f.authenticatable true
  f.password_changeable true
  f.lockable true
  f.group true
  f.params({
    check: true,
    username: "user",
    password: "password",
    label: "label",
    email: "user@exmaple.com",
  })
end
