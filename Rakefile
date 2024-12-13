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
  directory root_dir
  directory image_dir

  desc "ベンダーファイル生成"
  task build: [:build_image]

  task build_image: [image_dir] do
    bootstrap_icons_dir = "node_modules/bootstrap-icons"
    cp "#{bootstrap_icons_dir}/bootstrap-icons.svg", image_dir
  end
end
