# frozen_string_literal: true

# TODO: esbuildでbundleしない時に必要になるかもしれない。

require "json"

module Yuzakan
  module Views
    module Helpers
      module ImportmapHelper
        ASSETS_MAP = {"~/" => "/assets/"}.freeze
        JS_LIBRARIES_MAP = %w[
          @hyperapp/dom
          @hyperapp/events
          @hyperapp/html
          @hyperapp/svg
          @hyperapp/time
          bootstrap
          csv
          file-saver
          hljs
          http-link-header
          hyperapp
          luxon
          pluralize
          ramda
          xxhashjs
          zxcvbn
        ].to_h { |name| [name, "/assets/vendor/#{name}.js"] }.freeze

        def importmap
          html.script(type: "importmap") do
            raw({imports: imports_assets}.to_json)
          end
        end

        def imports_assets
          assets_json_path = Hanami.root / "public/assets.json"
          if Hanami.env?(:production) && assets_json_path.readable?
            assets_json = JSON.parse(assets_json_path.read)
            assets_map = assets_json
              .select { |path, _| path.end_with?(".js") }
              .to_h { |path, obj|
              [path.gsub(%r{^/assets/}, "~/"),
                obj["target"],]
            }
            js_libraries_map = JS_LIBRARIES_MAP.transform_values { |path|
              assets_json.dig(path, "target") || path
            }
            ASSETS_MAP.merge(assets_map, js_libraries_map)
          else
            ASSETS_MAP.merge(JS_LIBRARIES_MAP)
          end
        end
      end
    end
  end
end
