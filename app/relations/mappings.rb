# frozen_string_literal: true

module Yuzakan
  module Relations
    class Mappings < Yuzakan::DB::Relation
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
        ["student", "学生"],
        ["faculty", "教員"],
        ["staff", "職員"],
        ["member", "構成員"],
        ["guest", "ゲスト"],
        ["organization", "組織"],
      ].freeze
      E2J_DICT = E2J_LIST.to_h
      J2E_DICT = E2J_LIST.to_h(&:reverse)



      schema :mappings, infer: true do
        associations do
          belongs_to :service
          belongs_to :attr
        end
      end
    end
  end
end
