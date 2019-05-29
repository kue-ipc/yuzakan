source 'https://rubygems.org'

gem 'rake'
gem 'hanami',       '~> 1.3'
gem 'hanami-model', '~> 1.3'

gem 'sqlite3'

gem 'slim'

gem 'sass'
gem 'sassc'

gem 'coffee-script'

gem 'net-ldap'

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
