# frozen_string_literal: true

require 'rake'
require 'hanami/rake_tasks'
require 'rake/testtask'
require 'rake/clean'

CLEAN << 'vendor/assets'

CLOBBER << 'node_modules'
CLOBBER << 'rollup.config.js'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs << 'spec'
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

  rule 'vendor/assets/fonts' do
    mkdir_p 'vendor/assets/fonts'
  end

  task build_font: ['vendor/assets/fonts'] do
    source_code_pro_dir = 'node_modules/source-code-pro'
    font_list = [
      'WOFF2/TTF/SourceCodePro-Regular.ttf.woff2',
      'WOFF2/TTF/SourceCodePro-It.ttf.woff2',
      'WOFF2/TTF/SourceCodePro-Bold.ttf.woff2',
      'WOFF2/TTF/SourceCodePro-BoldIt.ttf.woff2',
      'WOFF/OTF/SourceCodePro-Regular.otf.woff',
      'WOFF/OTF/SourceCodePro-It.otf.woff',
      'WOFF/OTF/SourceCodePro-Bold.otf.woff',
      'WOFF/OTF/SourceCodePro-BoldIt.otf.woff',
    ]
    font_list.each do |font|
      name = File.basename(font).sub(/\.(ttf|otf)\./, '.')
      cp "#{source_code_pro_dir}/#{font}", "vendor/assets/fonts/#{name}"
    end
  end

  desc 'ベンダービルド'
  task build: [:build_js, :build_font]
end
