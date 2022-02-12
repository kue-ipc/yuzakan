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
      else
        @password = @size.times.map {
          @chars[SecureRandom.random_number(@chars.size)]
        }.join
      end
  end
end
