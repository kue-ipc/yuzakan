require 'hanami/interactor'

class GeneratePassword
  include Hanami::Interactor

  expose :password

  def initialize(size: 16,
                 chars: :alphanumeric,
                 exclude: [])
    @size = size
    exclude = exclude.chars if exclude.is_a?(String)
    @chars =
      case chars
      when :alphanumeric
        ['0'..'9', 'A'..'Z', 'a'..'z'].flat_map(&:to_a)
      when :ascii
        ("\x20".."\x7e").to_a
      when String
        chars.chars
      else
        chars
      end.-(exclude).uniq
  end

  def call(params = {}) # rubocop:disable Lint/UnusedMethodArgument
    @password = @size.times.map do
      @chars[SecureRandom.random_number(@chars.size)]
    end.join
  end
end
