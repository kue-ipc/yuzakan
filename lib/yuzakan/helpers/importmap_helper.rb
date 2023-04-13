# frozen_string_literal: true

require 'json'

module Yuzakan
  module Helpers
    module ImportmapHelper
      private def importmap
        html.script(type: 'importmap') do
          raw({
            imports: all_imports,
          }.to_json)
        end
      end

      private def all_imports
        asset_json = Hanami.root + 'public/assets.json'
        if Hanami.env == 'production' && asset_json.file?
          JSON.parse(asset_json.read).to_h do |path, obj|
            [path.gsub(%r{^/assets/}, '@'), obj['target']] if path.end_with?('.js')
          end.compact
        else
          {
            '@' => '/assets/',
          }
        end
      end
    end
  end
end
