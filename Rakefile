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

# task default: :test
task spec: :test

task build: [:build_errors, 'vendor:build']

rule 'public/errors' do
  mkdir_p 'public/errors'
end

task build_errors: 'public/errors' do
  %w[
    400 401     403 404 405 418
    500     502 503 504
  ].each do |code|
    src = "apps/web/templates/#{code}.html.slim"
    dst = "public/errors/#{code}.html"
    sh "bundle exec slimrb #{src} > #{dst}"
  end
end

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
    fonts_dir = 'vendor/assets/fonts'
    bootstrap_icons_dir = 'node_modules/bootstrap-icons/font'
    cp Dir.glob("#{bootstrap_icons_dir}/fonts/*.{woff,woff2}"), fonts_dir

    source_code_pro_dir = 'node_modules/source-code-pro'
    Dir.glob("#{source_code_pro_dir}/WOFF2/TTF/*.ttf.woff2").each do |path|
      cp path, "#{fonts_dir}/#{File.basename(path, '.ttf.woff2')}.woff2"
    end
    Dir.glob("#{source_code_pro_dir}/WOFF/OTF/*.otf.woff").each do |path|
      cp path, "#{fonts_dir}/#{File.basename(path, '.otf.woff')}.woff"
    end
  end

  rule 'vendor/assets/images' do
    mkdir_p 'vendor/assets/images'
  end

  task build_image: ['vendor/assets/images'] do
    images_dir = 'vendor/assets/images'
    
    bootstrap_icons_dir = 'node_modules/bootstrap-icons'
    cp "#{bootstrap_icons_dir}/bootstrap-icons.svg", images_dir
  end

  desc 'ベンダービルド'
  task build: [:build_js, :build_font, :build_image]
end
