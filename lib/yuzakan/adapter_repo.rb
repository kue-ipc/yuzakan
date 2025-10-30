# frozen_string_literal: true

module Yuzakan
  class AdapterRepo
    AdapterStruct = Data.define(:name, :class)

    def initialize
      @store = {}
    end

    def all = @store.values
    def clear = @store.clear

    def get(name) = @store[name]
    def set(name, class:) = @store.store(name, AdapterStruct.new(name:, class:))
    def unset(name) = @store.delete(name)
    def exist?(name) = @store.key?(name)
    def list = @store.keys
  end
end
