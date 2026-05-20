# frozen_string_literal: true

namespace :js do
  desc "Install JavaScript dependencies"
  task install: "node_modules"

  task test: ["node_modules"] do
    desc "Run JavaScript tests"
    sh "npm run test"
  end

  file "node_modules" => ["package.json", "package-lock.json"]
end
