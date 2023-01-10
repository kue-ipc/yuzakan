source 'https://rubygems.org'

gem 'hanami', '~> 2.0'
gem 'hanami-router', '~> 2.0'
gem 'hanami-controller', '~> 2.0'
gem 'hanami-validations', '~> 2.0'

gem 'dry-types', '~> 1.0', '>= 1.6.1'
gem 'puma'
gem 'rake'

gem 'rom', '~> 5.3'
gem 'rom-sql', '~> 3.6'
# Database
gem 'mysql2'
# gem 'pg'
# gem 'sqlite3'

# templates
gem 'slim'
gem 'sassc'
gem 'coffee-script'
gem 'uglifier'
gem 'terser'

# utils
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

group :development, :test do
  gem 'dotenv'
end

group :cli, :development do
  gem 'hanami-reloader'
end

group :cli, :development, :test do
  gem 'hanami-rspec'
end

group :development do
  gem 'guard-puma', '~> 0.8'
end

group :test do
  gem 'rack-test'
  gem 'database_cleaner-sequel'

  # minitest spec
  gem 'minitest'
  gem 'capybara'
  gem 'rr', require: false
end

group :production do
  # for puma on systemd
  gem 'sd_notify'
end
