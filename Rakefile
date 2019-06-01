# frozen_string_literal: true

require 'rake'
require 'hanami/rake_tasks'
require 'rake/testtask'
require 'fileutils'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs    << 'spec'
  t.warning = false
end

task default: :test
task spec: :test

rule '.js' => ['.coffee'] do |t|
  sh "yarn run coffee -c #{t.source}"
end

task vendor: ['rollup.config.js'] do
  sh 'yarn run rollup -c'
end
