# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'

# bug? 0.9.0 confilcet 0.10.0 error
gem 'dry-container', '~> 0.8.0'

gem 'rack', '>= 2.2.2'

# Database
gem 'mysql2'
# gem 'pg'
# gem 'sqlite3'

gem 'slim'

gem 'sassc'

gem 'opal'
gem 'coffee-script'
gem 'terser'

gem 'bcrypt'
gem 'zxcvbn-js', require: 'zxcvbn'

gem 'i18n'

# key-value storage
gem 'redis-rack'
gem 'readthis'

# LDAP
gem 'net-ldap'
gem 'smbhash'

# Google Workspace
gem 'google-apis-admin_directory_v1'

# xxHash
gem 'xxhash'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'shotgun', platforms: :ruby
  gem 'hanami-webconsole'
  gem 'rubocop'
end

group :test, :development do
  gem 'dotenv', '~> 2.4'
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'capybara'
end

group :production do
  gem 'puma', '~> 5.6'
  gem 'sd_notify'
end
