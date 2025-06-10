# frozen_string_literal: true

require "securerandom"

module Yuzakan
  module Operations
    class GeneratePassword < Yuzakan::Operation
      TYPES = %w[
        ascii
        alphanumeric
        letter
        upper_letter
        lower_letter
        digit
        upper_hex
        lower_hex
        custom
      ].freeze

      include Deps[
        "repo.config_repo"
      ]
      def call
        config = step current_config
        rule = step rule_from_config(config)
        step generate_password(rule)
      end

      private def current_config
        config = config_repo.current
        if config
          Success(config)
        else
          Failure([:failure, t("errors.uninitialized")])
        end
      end

      private def rule_from_config(config)
        Success({
          size: config.generate_password_size,
          type: config.generate_password_type,
          chars: config.generate_password_chars,
        })
      end

      private def generate_password(rule)
        return Failure([:invalid, {size: [gt?: 0]}]) unless rule[:size].positive?

        char_list = charlist_from_rule(rule).value_or { return Failure(_1) }
        return Failure([:invalid, {char_list: [:filled?]}]) if char_list.empty?

        password = rule[:size].times.map do
          char_list[SecureRandom.random_number(char_list.size)]
        end.join
        Success(password)
      rescue NotImplementedError => e
        Failure([:error, e])
      end

      private def charlist_from_rule(rule)
        chars =
          case rule[:type]
          in "ascii"
            ("\x20".."\x7e").to_a
          in "alphanumeric"
            ["0".."9", "A".."Z", "a".."z"].flat_map(&:to_a)
          in "letter"
            ["A".."Z", "a".."z"].flat_map(&:to_a)
          in "upper_letter"
            ("A".."Z").to_a
          in "lower_letter"
            ("a".."z").to_a
          in "digit"
            ("0".."9").to_a
          in "upper_hex"
            ["0".."9", "A".."F"].flat_map(&:to_a)
          in "lower_hex"
            ["0".."9", "a".."f"].flat_map(&:to_a)
          in "custom"
            nil
          else
            return Failure(
              [:invalid, {type: [:included_in?]}])
          end
        chars = chars&.difference(rule[:chars].chars) || rule[:chars].chars
        Success(chars.uniq)
      end
    end
  end
end
