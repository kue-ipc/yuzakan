# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'
gem 'hanami-events', git: 'https://github.com/hanami/events.git'

gem 'slim'

gem 'sass'
gem 'sassc'

gem 'coffee-script'

gem 'bcrypt'
gem 'net-ldap'
gem 'zxcvbn-ruby'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'shotgun', platforms: :ruby
  gem 'hanami-webconsole'
end

group :test, :development do
  gem 'dotenv', '~> 2.4'
  gem 'pry'
  gem 'sqlite3'

end

group :test do
  gem 'minitest'
  gem 'capybara'
end

group :production do
  gem 'puma'
  # gem 'mysql2'
  # gem 'pg'
end
