# frozen_string_literal: true

require "rake"
require "hanami/rake_tasks"
require "rake/clean"

CLEAN << "public"

CLOBBER << "node_modules"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: [:spec, "js:test"]
rescue LoadError
  # do nothing
end

namespace :cache do
  desc "Remove any caches"
  task clean: :environment do
    Hanami.app["cache_store"].clear
  end
end

namespace :js do
  desc "Run JavaScript tests"
  task test: ["node_modules/.bin/mocha"] do
    sh "npm run test"
  end

  rule %r{^node_modules/.*$} do
    sh "npm install"
  end
end
