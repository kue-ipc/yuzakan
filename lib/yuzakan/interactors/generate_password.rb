require 'hanami/interactor'

class GeneratePassword
  include Hanami::Interactor

  expose :password

  def initialize(size: 16,
                 chars: :alphanumeric)
    @size = size
    @chars = chars
  end

  def call(_params = {})
    @password =
      if @chars == :alphanumeric
        SecureRandom.alphanumeric(@size)
      elsif @chars == :ascii
        chars = ("\x20".."\x7e").to_a
        @password = @size.times.map do
          chars[SecureRandom.random_number(chars.size)]
        end.join
      else
        @password = @size.times.map do
          @chars[SecureRandom.random_number(@chars.size)]
        end.join
      end
  end
end
