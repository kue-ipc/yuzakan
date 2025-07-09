# frozen_string_literal: true

Factory.define(:attr) do |f|
  f.name Faker::Internet.username
  f.label "" # default
  f.description "" # default
  f.category "user"
  f.type "string"
  f.order 1
  f.hidden false # default
  f.readonly false # default
  f.code "" # default
  f.timestamps
end

Factory.define(another_attr: :attr) do |f|
  f.name Faker::Internet.username
  f.label Faker::Team.name
  f.description Faker::Lorem.sentence
  f.category "group"
  f.type "boolean"
  f.order 42
  f.hidden true
  f.readonly true
  f.code "=>()"
  f.timestamps
end
