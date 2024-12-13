# frozen_string_literal: true

require "rake"
require "hanami/rake_tasks"
require "rake/clean"
require "tempfile"

CLEAN << "vendor/assets"
CLEAN << "public/assets"
CLEAN << "public/errors"
CLEAN << "rollup.config.mjs"

CLOBBER << "node_modules"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  # do nothing
end

desc "ファイル生成"
task build: [:build_errors, "vendor:build"]

desc "エラーファイル生成"
task build_errors: %w[
  400 401 403 404 405 418
  500 502 503 504
].map { |code| "public/errors/#{code}.html" }

rule %r{^public/errors/\d+\.html$} => ["apps/web/templates/%n.html.slim", "public/errors"] do |t|
  sh "bundle exec slimrb #{t.source} > #{t.name}"
end

rule "public/errors" do
  mkdir_p "public/errors"
end

namespace :vendor do
  root_dir = "vendor/assets"
  image_dir = "#{root_dir}/images"
  font_dir = "#{root_dir}/fonts"
  directory root_dir
  directory image_dir
  directory font_dir

  desc "ベンダーファイル生成"
  task build: [:build_js, :build_font, :build_image]

  task build_font: [font_dir] do
    bootstrap_icons_dir = "node_modules/bootstrap-icons/font"
    cp Dir.glob("#{bootstrap_icons_dir}/fonts/*.{woff,woff2}"), font_dir

    source_code_pro_dir = "node_modules/source-code-pro"
    ["OTF", "VAR"].each do |type|
      ["woff", "woff2"].each do |ext|
        Dir.glob("#{source_code_pro_dir}/#{ext.upcase}/#{type}/*.otf.#{ext}").each do |path|
          cp path, "#{font_dir}/#{File.basename(path, ".otf.#{ext}")}.#{ext}"
        end
      end
    end

    firacode_dir = "node_modules/firacode"
    cp Dir.glob("#{firacode_dir}/distr/woff/*.woff"), font_dir
    cp Dir.glob("#{firacode_dir}/distr/woff2/*.woff2"), font_dir

    typopro_web_iosevka_dir = "node_modules/@typopro/web-iosevka"
    cp Dir.glob("#{typopro_web_iosevka_dir}/*.woff"), font_dir
  end

  task build_image: [image_dir] do
    bootstrap_icons_dir = "node_modules/bootstrap-icons"
    cp "#{bootstrap_icons_dir}/bootstrap-icons.svg", image_dir
  end
end
