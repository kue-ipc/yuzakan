# frozen_string_literal: true

require 'rake'
require 'hanami/rake_tasks'
require 'rake/clean'
require 'tempfile'

CLEAN << 'vendor/assets'
CLEAN << 'public/assets'
CLEAN << 'public/errors'
CLEAN << 'rollup.config.mjs'

CLOBBER << 'node_modules'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

desc 'ファイル生成'
task build: [:build_errors, 'vendor:build']

desc 'エラーファイル生成'
task build_errors: %w[
  400 401 403 404 405 418
  500 502 503 504
].map { |code| "public/errors/#{code}.html" }

rule %r{^public/errors/\d+\.html$} => ['apps/web/templates/%n.html.slim', 'public/errors'] do |t|
  sh "bundle exec slimrb #{t.source} > #{t.name}"
end

rule 'public/errors' do
  mkdir_p 'public/errors'
end

namespace :vendor do
  desc 'ベンダーファイル生成'
  task build: [:build_js, :build_font, :build_image]

  task build_js: [:build_js_rollup, :build_js_hyperapp, :build_js_opal]

  task build_js_rollup: ['rollup.config.mjs', 'node_modules/.bin/rollup'] do
    sh 'npx rollup -c'
  end

  rule '.mjs' => ['.coffee', 'node_modules/.bin/coffee'] do |t|
    sh "npx coffee -o #{t.name} -c #{t.source}"
  end

  rule %r{^node_modules/.*$} do
    sh 'npm install'
  end

  task build_js_hyperapp: ['html', 'svg'].map { |name| "vendor/assets/javascripts/hyperapp-#{name}.js" }

  rule %r{^vendor/assets/javascripts/hyperapp-.*\.js$} => 'node_modules/@hyperapp/%{hyperapp-,}n/index.js' do |t|
    js_data = File.read(t.source)
    [
      '(\b(?:im|ex)port\b[\s\w,*{}]*\bfrom\b\s*)"([^"]*)"',
      '(\bimport\b\s*)"([^"]*)"',
      '(\bimport\b\s*\(\s*)"([^"]*)"(\s*\))',
    ].each do |re_str|
      js_data.gsub!(Regexp.compile(re_str), '\1"~/vendor/\2.js"\3')
      js_data.gsub!(Regexp.compile(re_str.tr('"', "'")), '\1\'~/vendor/\2.js\'\3')
    end
    File.write(t.name, js_data)
  end

  task build_js_opal: ['vendor/assets/javascripts'] do
    stdlibs = %w[
      js
      native
    ]

    Tempfile.open do |fp|
      fp.puts '`Opal`'
      fp.close

      cmd = %w[
        opal
        --no-source-map
        --no-exit
        --esm
        --no-cache
        --compile
        --output vendor/assets/javascripts/opal.js
      ]
      stdlibs.each do |lib|
        cmd << '--require'
        cmd << lib
      end
      cmd << '--'
      cmd << fp.path

      sh(*cmd)
    end
  end

  task build_font: ['vendor/assets/fonts'] do
    fonts_dir = 'vendor/assets/fonts'
    bootstrap_icons_dir = 'node_modules/bootstrap-icons/font'
    cp Dir.glob("#{bootstrap_icons_dir}/fonts/*.{woff,woff2}"), fonts_dir

    source_code_pro_dir = 'node_modules/source-code-pro'
    ['OTF', 'VAR'].each do |type|
      ['woff', 'woff2'].each do |ext|
        Dir.glob("#{source_code_pro_dir}/#{ext.upcase}/#{type}/*.otf.#{ext}").each do |path|
          cp path, "#{fonts_dir}/#{File.basename(path, ".otf.#{ext}")}.#{ext}"
        end
      end
    end

    firacode_dir = 'node_modules/firacode'
    cp Dir.glob("#{firacode_dir}/distr/woff/*.woff"), fonts_dir
    cp Dir.glob("#{firacode_dir}/distr/woff2/*.woff2"), fonts_dir

    typopro_web_iosevka_dir = 'node_modules/@typopro/web-iosevka'
    cp Dir.glob("#{typopro_web_iosevka_dir}/*.woff"), fonts_dir
  end

  rule 'vendor/assets/fonts' do
    mkdir_p 'vendor/assets/fonts'
  end

  task build_image: ['vendor/assets/images'] do
    images_dir = 'vendor/assets/images'
    bootstrap_icons_dir = 'node_modules/bootstrap-icons'
    cp "#{bootstrap_icons_dir}/bootstrap-icons.svg", images_dir
  end

  rule 'vendor/assets/images' do
    mkdir_p 'vendor/assets/images'
  end
end
