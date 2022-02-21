require 'hanami/http/status'

module Api
  module MessageJson
    private def halt_json(code, message = nil, **others)
      halt(code, JSON.generate({
        code: code,
        message: message || Hanami::Http::Status.message_for(code),
        **others,
      }))
    end

    private def redirect_to_json(url, message = nil, status: 320, **others)
      url = url.to_s
      headers['Location'] = url
      halt_json(status, message, location: url, **others)
    end
  end
end
