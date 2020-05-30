# frozen_string_literal: true

require 'rake'
require 'hanami/rake_tasks'
require 'rake/testtask'
require 'rake/clean'
require 'shell'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs    << 'spec'
  t.warning = false
end

task default: :test
task spec: :test

namespace :vendor do
  rule %r{^node_modules/.bin/.*$} do
    sh 'yarn install'
  end

  rule '.js' => ['.coffee', 'node_modules/.bin/coffee'] do |t|
    sh "node_modules/.bin/coffee -c #{t.source}"
  end

  task build_js: ['rollup.config.js', 'node_modules/.bin/rollup'] do
    sh 'node_modules/.bin/rollup -c'
  end

  desc 'ベンダービルド'
  task build: [:build_js]
end
