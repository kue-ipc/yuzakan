# frozen_string_literal: true

def struct_to_hash(struct, except: [], **opts)
  hash = struct.to_h.except(:id, :created_at, :updated_at, *except)

  hash.keys.select { |key| key.end_with?("_id") }.each do |key|
    name = key.to_s.delete_suffix("_id").intern
    if except.include?(name)
      hash.delete(name)
    else
      value = hash[name]
      hash[name] = value&.fetch(:name)
    end
    hash.delete(key)
  end

  case opts[:case]
  in :camel
    hash.transform_keys! do |key|
      str = Hanami::Utils::String.classify(key.to_s)
      (str[0].downcase + str[1..]).intern
    end
  in :pascal
    hash.transform_keys! do |key|
      Hanami::Utils::String.classify(key.to_s).intern
    end
  in :snake | nil
    # do nothing
  end

  hash
end
