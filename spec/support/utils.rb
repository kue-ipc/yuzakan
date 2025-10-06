# frozen_string_literal: true

def struct_to_hash(struct, except: [])
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
  hash
end
