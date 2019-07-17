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
    [
      {src: 'bootstrap/dist/css/bootstrap.css', dst: 'theme_default.css'},
      {src: 'bootstrap/dist/css/bootstrap.css', dst: 'theme_bootstrap.css'},
      {src: 'startbootstrap-sb-admin/css/sb-admin.css',
        dst: 'theme_sb-admin.css'},
      {src: 'startbootstrap-sb-admin-2/css/sb-admin-2.css',
        dst: 'theme_sb-admin-2.css'},
    ].each do |target|
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
