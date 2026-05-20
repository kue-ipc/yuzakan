# frozen_string_literal: true

namespace :js do
  desc "Run JavaScript tests"
  task test: ["node_modules/.bin/mocha"] do
    sh "npm run test"
  end

  rule %r{^node_modules/.*$} do
    sh "npm install"
  end
end
