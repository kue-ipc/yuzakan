# frozen_string_literal: true

Factory.define(:config) do |f|
  f.title Faker::Team.name
  f.description Faker::Lorem.sentence
  f.domain Faker::Internet.domain_name
  f.session_timeout 3600 # default
  f.auth_failure_waiting 2 # default
  f.auth_failure_limit 5 # default
  f.auth_failure_duration 600 # default
  f.password_min_size 8 # default
  f.password_max_size 64 # default
  f.password_min_types 1 # default
  f.password_min_score 0 # default
  f.password_prohibited_chars "" # default
  f.password_extra_dict [] # default
  f.generate_password_size 24 # default
  f.generate_password_type "ascii" # default
  f.generate_password_chars " " # default
  f.contact_name Faker::Name.name
  f.contact_email Faker::Internet.email
  f.contact_phone Faker::PhoneNumber.phone_number
  f.timestamps
end

Factory.define(config_with_nil: :config) do |f|
  f.domain nil
  f.contact_name nil
  f.contact_email nil
  f.contact_phone nil
end

Factory.define(another_config: :config) do |f|
  f.title Faker::Team.name
  f.description Faker::Lorem.sentence
  f.domain Faker::Internet.domain_name
  f.session_timeout 7200
  f.auth_failure_waiting 10
  f.auth_failure_limit 1
  f.auth_failure_duration 60
  f.password_min_size 1
  f.password_max_size 8
  f.password_min_types 0
  f.password_min_score 1
  f.password_prohibited_chars "'\""
  f.password_extra_dict ["dummy"]
  f.generate_password_size 8
  f.generate_password_type "alphanumeric"
  f.generate_password_chars "1Il0O"
  f.contact_name Faker::Name.name
  f.contact_email Faker::Internet.email
  f.contact_phone Faker::PhoneNumber.phone_number
  f.timestamps
end

Factory.define(no_waiting_auth_failure_config: :config) do |f|
  f.auth_failure_waiting 0
end
