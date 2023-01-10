# frozen_string_literal: true

class AttrMapping < Hanami::Entity
  CONVERSIONS = %w[
    posix_time
    posix_date
    path
    e2j
    j2e
  ].freeze

  TRUE_STR_VALUES = %w[true yes on].freeze
  TRUE_VALUES = [true, 1] +
                TRUE_STR_VALUES +
                TRUE_STR_VALUES.map(&:upcase) +
                TRUE_STR_VALUES.map(&:intern)

  FALSE_STR_VALUES = %w[false no off].freeze
  FALSE_VALUES = [nil, false, 0] +
                 FALSE_STR_VALUES +
                 FALSE_STR_VALUES.map(&:upcase) +
                 FALSE_STR_VALUES.map(&:intern)

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

  def attr_name
    attr.name
  end

  # Adapter data -> Ruby data
  def convert_value(value)
    return if value.nil?

    if conversion.nil?
      case attr.type
      when 'boolean'
        if TRUE_VALUES.include?(value)
          true
        elsif FALSE_VALUES.include?(value)
          false
        end
      when 'string'
        value.to_s
      when 'integer'
        value.to_i
      when 'float'
        value.to_f
      when 'date'
        value.to_date
      when 'time', 'datetime'
        value.to_time
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
  alias convert convert_value

  # Ruby data -> Adapter data
  def map_value(value)
    return if value.nil?

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
  alias reverse_convert map_value

  def translate_e2j(value)
    E2J_DICT[value] || value
  end

  def translate_j2e(value)
    J2E_DICT[value] || value
  end
end
