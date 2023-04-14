# frozen_string_literal: true

require 'json'

module Yuzakan
  module Helpers
    module ImportmapHelper
      ASSETS_MAP = {'~/' => '/assets/'}.freeze

      private def importmap
        html.script(type: 'importmap') do
          raw({
            imports: imports_assets,
          }.to_json)
        end
      end

      private def imports_assets
        assets_json = Hanami.root / 'public/assets.json'
        if Hanami.env == 'production' && assets_json.readable?
          assets_map = JSON.parse(assets_json.read)
            .select { |path, _| path.end_with?('.js') }
            .to_h { |path, obj| [path.gsub(%r{^/assets/}, '~/'), obj['target']] }
          ASSETS_MAP.merge(assets_map)
        else
          ASSETS_MAP
        end
      end
    end
  end
end
