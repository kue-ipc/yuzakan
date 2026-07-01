# frozen_string_literal: true

# Handlebars

Hanami.app.register_provider(:handlebars) do
  prepare do
    require "handlebars-engine"
  end

  start do
    handlebars = Handlebars::Engine.new

    handlebars.register_helper(:upcase) do |_ctx, *args, _opts|
      str = args.first.to_s
      str.upcase
    end

    handlebars.register_helper(:downcase) do |_ctx, *args, _opts|
      str = args.first.to_s
      str.downcase
    end

    handlebars.register_helper(:slice) do |_ctx, *args, _opts|
      str = args[0].to_s
      start = args[1].to_i
      length = args[2]&.to_i
      if length.nil?
        str.slice(start)
      else
        str.slice(start, length)
      end
    end

    handlebars.register_helper(:strip) do |_ctx, *args, opts|
      str = args.first.to_s
      case opts[:whitespace]
      when ""
        # TODO: ここまで
      else
        str.sub(/\A\p{White_Space}+/, "").sub(/\p{White_Space}+\z/, "")
      end
    end

    register "handlebars", handlebars
  end
end
