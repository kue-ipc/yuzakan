# frozen_string_literal: true

class ProviderAttrMapping < Hanami::Entity
  def convert(value)
    if conversion.nil?
      case attr_type.type
      when 'boolean'
        nil | value
      when 'string'
        value.to_s
      when 'integer'
        value.to_i
      when 'float'
        value.to_f
      when 'date'
        value.to_date
      when 'time'
        value.to_time
      when 'datetime'
        value.to_datetime
      else
        value
      end
    else
      case conversion
      when 'posix_time'
        Time.at(value.to_i)
      when 'posix_date'
        Date.new(1970, 1, 1) + value.to_i
      when 'path'
        value.sub(/^\/+/, '')
      else
        value
      end
    end
  end

  def reverse_convert(value)
    return value if conversion.nil?

    case conversion
    when 'posix_time'
      value.to_time.to_i
    when 'posix_date'
      (Date.new(1970, 1, 1) - value.to_date).to_i
    when 'path'
      '/' + value
    else
      value
    end
  end
end
