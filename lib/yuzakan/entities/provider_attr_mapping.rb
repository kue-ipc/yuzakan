# frozen_string_literal: true

class ProviderAttrMapping < Hanami::Entity
  def convert(value)
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
  end
end
