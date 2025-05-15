# frozen_string_literal: true

source "https://rubygems.org"

gem "hanami", "~> 2.2"
gem "hanami-assets", "~> 2.2"
gem "hanami-controller", "~> 2.2"
gem "hanami-db", "~> 2.2"
gem "hanami-router", "~> 2.2"
gem "hanami-validations", "~> 2.2"
gem "hanami-view", "~> 2.2"

gem "dry-types", "~> 1.7"
gem "dry-operation"
gem "puma"
gem "rake"

# Database
gem "pg"
# gem "mysql2"
# gem "sqlite3"

# Template
gem "slim"
gem "kramdown"
gem "kramdown-parser-gfm"

# Redis
gem "hiredis"
gem "redis", require: ["redis", "redis/connection/hiredis"]
gem "redis-rack"

# Uitls
gem "activesupport", "~> 8.0"
gem "i18n"
gem "bcrypt"
gem "zxcvbn"
gem "digest-xxhash"

## for adapter ##

# LDAP
gem "net-ldap"
# FIXME: https://github.com/ruby-ldap/ruby-net-ldap/issues/431
gem "ostruct"
gem "smbhash"

# Google Workspace
gem "google-apis-admin_directory_v1"

group :development do
  gem "hanami-webconsole", "~> 2.2"

  # Rubocop
  gem "rubocop"
  gem "rubocop-capybara"
  gem "rubocop-rake"
  gem "rubocop-rspec"

  # Ruby LSP and Debug
  gem "ruby-lsp", require: false
  gem "debug", require: false, platforms: :mri
end

group :development, :test do
  gem "dotenv"
end

group :cli, :development do
  gem "hanami-reloader", "~> 2.2"
end

group :cli, :development, :test do
  gem "hanami-rspec", "~> 2.2"
end

group :test do
  # Database
  gem "database_cleaner-sequel"
  gem "rom-factory"

  # Web integration
  gem "capybara"
  gem "rack-test"
end
