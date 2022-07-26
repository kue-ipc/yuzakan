require 'ipaddr'

class Network < Hanami::Entity
  attr_reader :ipaddr

  def initialize(attributes = nil)
    return super if attributes.nil? # rubocop:disable Lint/ReturnInVoidContext

    @ipaddr = IPAddr.new(attributes[:address])
    super
  end

  def include?(addr)
    @ipaddr.include?(addr)
  end

  def to_s
    "#{@ipaddr}/#{@ipaddr.prefix}"
  end
end
