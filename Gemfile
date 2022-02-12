source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'

# FIXME: don't update dry-configurable
# maybe 0.13.0 have a bug
gem 'dry-configurable', '~> 0.12.1'

gem 'rack', '>= 2.2.2'

# Database
gem 'mysql2'
# gem 'pg'

gem 'slim'

# gem 'sass'
gem 'sassc'

gem 'coffee-script'
gem 'uglifier'

gem 'bcrypt'
gem 'zxcvbn-js', require: 'zxcvbn'

# key-value storage
gem 'redis-rack'
# gem 'dalli'
gem 'readthis'

# default gem
gem 'ipaddr'

# Pager
gem 'pagy'

# LDAP
gem 'net-ldap'
gem 'smbhash'

# Google Workspace
gem 'google-apis-admin_directory_v1'

# octicons
gem 'octicons'

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
  gem 'sqlite3'
end

group :production do
  gem 'puma', '~> 5.6'
  gem 'sd_notify'
end
