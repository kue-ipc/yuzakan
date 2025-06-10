# frozen_string_literal: true

# TODO: body_parserを分析してみた結果、いらないかもしれない。

require "json"
require "hanami/utils/string"
require_relative "../utils/key_transformer"

class JsonKeyTransformer
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["CONTENT_TYPE"]&.include?("application/json")
      req = Rack::Request.new(env)
      if req.body.size.positive?
        req.body.rewind
        raw_body = req.body.read
        begin
          parsed = JSON.parse(raw_body)
          transformed = Utils::KeyTransformer.camel_to_snake_keys(parsed)
          env["rack.input"] = StringIO.new(transformed.to_json)
        rescue JSON::ParserError
          # 無視してそのまま通す
        end
      end
    end

    @app.call(env)
  end



    def self.camel_to_snake_keys(obj)
      case obj
      when Array
        obj.map { |v| camel_to_snake_keys(v) }
      when Hash
        obj.each_with_object({}) do |(k, v), result|
          new_key = k.to_s.gsub(/([A-Z])/, '_\1').downcase
          result[new_key] = camel_to_snake_keys(v)
        end
      else
        obj
      end
  end
end
