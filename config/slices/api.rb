module API
  class Slice < Hanami::Slice
    config.middleware.use :body_parser, :json
    config.actions.format :json
  end
end
