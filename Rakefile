# frozen_string_literal: true

require 'rake'
require 'hanami/rake_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs    << 'spec'
  t.warning = false
end

task default: :test
task spec: :test

namespace :vendor do
  rule %r{^node_modules/.bin/.*$} do
    sh 'npm install'
  end

  rule '.js' => ['.coffee', 'node_modules/.bin/coffee'] do |t|
    sh "node_modules/.bin/coffee -c #{t.source}"
  end

  task build_js: ['rollup.config.js', 'node_modules/.bin/rollup'] do
    sh 'node_modules/.bin/rollup -c'
  end

  task :build_css do
    list = [
      {
        src: 'bootstrap/dist/css/bootstrap.css',
        dst: 'theme_bootstrap.css'},
      {
        src: 'startbootstrap-sb-admin-2/css/sb-admin-2.css',
        dst: 'theme_startbootstrap-sb-admin-2.css',
      },
    ]

    bootswatch_list = %w[
      cerulean cosmo cyborg darkly flatly journal litera lumen lux materia
      minty pulse sandstone simplex sketchy slate solar spacelab superhero
      united yeti
    ].map do |name|
      {
        src: "bootswatch/dist/#{name}/bootstrap.css",
        dst: "theme_bootswatch-#{name}.css"
      }
    end

    (list + bootswatch_list).each do |target|
      [
        'apps/web/vendor/assets/stylesheets',
        'apps/admin/vendor/assets/stylesheets',
      ].each do |asset|
        parent_dir = "#{asset}"
        mkdir_p(parent_dir) unless FileTest.directory?(parent_dir)
        cp "node_modules/#{target[:src]}", "#{parent_dir}/#{target[:dst]}"
      end
    end
  end

  desc 'ベンダービルド'
  task build: [:build_js, :build_css]
end
