# frozen_string_literal: true

# Handlebars

Hanami.app.register_provider(:handlebars) do
  prepare do
    require "handlebars-engine"
    require "digest"
    require "digest/xxhash"
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
      if opts[:ascii]
        # [ \t\r\n\f\v]
        str.strip
      else
        str.sub(/\A\p{White_Space}+/, "").sub(/\p{White_Space}+\z/, "")
      end
    end

    handlebars.register_helper(:first_word) do |_ctx, *args, _opts|
      str = args.first.to_s
      if opts[:ascii]
        # [ \t\r\n\f\v]
        str.split.first || ""
      else
        # delete leading whitespace, split by whitespace, and return the first word
        str.sub(/\A\p{White_Space}+/, "").split(/\p{White_Space}+/).first || ""
      end
    end

    handlebars.register_helper(:last_word) do |_ctx, *args, _opts|
      str = args.first.to_s
      if opts[:ascii]
        # [ \t\r\n\f\v]
        str.split.last || ""
      else
        str.split(/\p{White_Space}+/).last || ""
      end
    end

    handlebars.register_helper(:digest) do |_ctx, *args, _opts|
      algo = args[0].to_s
      str = args[1].to_s
      case algo
      in "md5"
        Digest::MD5.hexdigest(str)
      in "sha1"
        Digest::SHA1.hexdigest(str)
      in "sha2" | "sha256"
        Digest::SHA256.hexdigest(str)
      in "sha384"
        Digest::SHA384.hexdigest(str)
      in "sha512"
        Digest::SHA512.hexdigest(str)
      in "xxh32"
        Digest::XXH32.hexdigest(str)
      in "xxh64"
        Digest::XXH64.hexdigest(str)
      in "xxh3" | "xxh3_64"
        Digest::XXH3_64bits.hexdigest(str)
      in "xxh3_128"
        Digest::XXH3_128bits.hexdigest(str)
      else
        # FIXME: コードが間違っているので、何らかのエラーを返すようにすべき？
        target["logger"].error "Unsupported digest algorithm: #{algo}"
        ""
      end
    end

    handlebars.register_helper(:dict) do |_ctx, *args, _opts|
      dict = args[0].to_s
      str = args[1].to_s
      case target["operations.lookup_dict"].call(dict, str)
      in Success(nil)
        ""
      in Success(description)
        description
      in Failure(failure)
        # FIXME: 辞書がないなど。何らかのエラーを返すべき？
        target["logger"].error "Failed to lookup dict: #{dict}, #{str}, #{failure}"
        ""
      end
    end

    register "handlebars", handlebars
  end
end
