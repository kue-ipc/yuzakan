# frozen_string_literal: true

require "rake/clean"

CLEAN << "public/assets" << "public/assets.json"
CLOBBER << "node_modules" << "vendor/bundle"
