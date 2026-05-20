# frozen_string_literal: true

require "rake/clean"

CLEAN << "public/assets"
CLOBBER << "node_modules" << "vendor/bundle"
