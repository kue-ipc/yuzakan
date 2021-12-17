class AttrMapping < Hanami::Entity
  def attr_name
    attr.name.intern
  end

  # Adapter data -> Ruby data
  def convert_value(value)
    if conversion.nil?
      case attr.type
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
        value.sub(%r{^/+}, '')
      when 'e2j'
        translate_e2j(value)
      when 'j2e'
        translate_j2e(value)
      else
        value
      end
    end
  end
  alias :convert :convert_value

  # Ruby data -> Adapter data
  def map_value(value)
    return value if conversion.nil?

    case conversion
    when 'posix_time'
      value.to_time.to_i
    when 'posix_date'
      (Date.new(1970, 1, 1) - value.to_date).to_i
    when 'path'
      "/#{value}"
    when 'e2j'
      translate_j2e(value)
    when 'j2e'
      translate_e2j(value)
    else
      value
    end
  end
  alias :reverse_convert :map_value 

  E2J_LIST = [
    ['student', '学生'],
    ['faculty', '教員'],
    ['staff', '職員'],
    ['member', '構成員'],
    ['guest', 'ゲスト'],
    ['organization', '組織'],
  ].freeze
  E2J_DICT = E2J_LIST.to_h
  J2E_DICT = E2J_LIST.map(&:reverse).to_h

  def translate_e2j(value)
    E2J_DICT[value] || value
  end

  def translate_j2e(value)
    J2E_DICT[value] || value
  end
end
