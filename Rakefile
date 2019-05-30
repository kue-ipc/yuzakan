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





task :vendor do
  system 'npm install'

  stylesheets = [
    ['bootstrap/dist/css/bootstrap.css', 'bootstrap.css']
  ]

  javascripts = [
    ['@fortawesome/fontawesome-free/js/all.js', 'fontawesome.js'],
    ['bootstrap.native/dist/bootstrap-native-v4.js', 'bootstrap-native.js'],
    ['hyperapp/dist/hyperapp.js', 'hyperapp.js'],
  ]

  stylesheets.each do |src, dst|
    FileUtils.copy('node_modules/' + src,
      'apps/admin/vendor/assets/stylesheets/' + dst)
  end

  javascripts.each do |src, dst|
    FileUtils.copy('node_modules/' + src,
      'apps/admin/vendor/assets/javascripts/' + dst)
  end
end
