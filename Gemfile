source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'

gem 'rack', '>= 2.2.2'

# Database
gem 'mysql2'
# gem 'pg'
# gem 'sqlite3'

gem 'slim'

gem 'sassc'

gem 'coffee-script'
gem 'uglifier'

gem 'bcrypt'
gem 'zxcvbn-js', require: 'zxcvbn'

gem 'i18n'

# key-value storage
gem 'redis-rack'
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
  gem 'rr', require: false
end

group :production do
  gem 'puma', '~> 5.6'
  gem 'sd_notify'
end
