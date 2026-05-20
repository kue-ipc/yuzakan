# frozen_string_literal: true

namespace :cache do
  desc "Remove any caches"
  task clean: :environment do
    Hanami.app["cache_store"].clear
  end
end
