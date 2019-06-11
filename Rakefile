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

def copy_css(src, dst)
  if FileTest.file?(src)
    if %w[.css .scss .sass].include?(File.extname(src))
      if File.basename(src) !~ /\A_/
        dst = File.join(File.dirname(dst), '_' + File.basename(src))
      end
      if !FileTest.file?(dst) || File.mtime(src) > File.mtime(dst)
        cp src, dst
      end
    end
  elsif FileTest.directory?(src)
    mkdir_p(dst) unless FileTest.directory?(dst)
    Dir.each_child(src) do |child|
      copy_css(File.join(src, child), File.join(dst, child))
    end
  end
end

task default: :test
task spec: :test

namespace :vendor do
  rule %r{^node_modules/.bin/*$} do
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
      {src: 'bootstrap/scss', dst: 'bootstrap'},
    ].each do |target|
      [
        'apps/web/vendor/assets/stylesheets',
        'apps/admin/vendor/assets/stylesheets',
      ].each do |asset|
        copy_css "node_modules/#{target[:src]}", "#{asset}/#{target[:dst]}"
      end
    end
  end

  desc 'ベンダービルド'
  task build: [:build_js, :build_css]
end
