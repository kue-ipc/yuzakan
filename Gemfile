# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'

gem 'rack', '>= 2.2.2'

# Database
# gem 'sqlite3'
gem 'mysql2'
# gem 'pg'

gem 'slim'

# gem 'sass'
gem 'sassc'

gem 'coffee-script'
gem 'uglifier'

gem 'bcrypt'
gem 'zxcvbn-js', require: 'zxcvbn'

# default gem
gem 'ipaddr'

# LDAP
gem 'net-ldap'
gem 'smbhash'

# G Suite
gem 'google-api-client'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'shotgun', platforms: :ruby
  gem 'hanami-webconsole'
end

group :test, :development do
  gem 'dotenv', '~> 2.4'
  gem 'pry'
end

group :test do
  gem 'minitest'
  gem 'capybara'
end

group :production do
  gem 'puma'
end
