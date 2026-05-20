# frozen_string_literal: true

require "rake"
require "rake/clean"
require "hanami/rake_tasks"

# Add your custom rake tasks to the lib/tasks directory
Rake.add_rakelib "lib/tasks"

CLEAN << "public/assets"

CLOBBER << "node_modules" << "vendor/bundle"

# TODO: lib/tasks以下に移動すべき。
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
