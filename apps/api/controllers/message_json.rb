module Api
  module MessageJson
    private def halt_json(code, message = nil, **others)
      halt(code, JSON.generate({
        code: code,
        message: message || Rack::Utils::HTTP_STATUS_CODES[code],
        **others,
      }))
    end
  end
end
