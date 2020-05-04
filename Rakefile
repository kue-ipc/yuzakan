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

  task :build_css do
    list = [
      {
        src: 'bootstrap/scss',
        dst: 'bootstrap',
      },
    ]

    list.each do |target|
      [
        'apps/admin/vendor/assets/stylesheets',
        'apps/web/vendor/assets/stylesheets',
        'apps/legacy/vendor/assets/stylesheets',
      ].each do |asset|
        parent_dir = "#{asset}"
        mkdir_p(parent_dir) unless FileTest.directory?(parent_dir)
        copy_entry "node_modules/#{target[:src]}",
                   "#{parent_dir}/#{target[:dst]}"
        Dir.glob("#{parent_dir}/#{target[:dst]}/**").each do |name|
          next unless FileTest.file?(name)
          if File.basename(name).start_with?(/[0-9A-Za-z]/)
            mv name, File.join(File.dirname(name), "_#{File.basename(name)}")
          end
        end
      end
    end
  end

  desc 'ベンダービルド'
  task build: [:build_js, :build_css]

  desc 'ベンダークリーン'

end
