# frozen_string_literal: true

require "yuzakan/db/repo"

module Yuzakan
  class AdapterRepo
    AdapterStruct = Data.define(:name, :class)

    def initialize
      @store = {}
    end

    def all = @store.values
    def clear = @store.clear

    def get(name) = @store[name]
    def get!(...) = get(...) || raise(Yuzakan::DB::Repo::NotFoundNameError, "Adapter not found: #{name}")
    def put(name, class:) = @store[name]&.with(class:)&.tap { |struct| @store[name] = struct }
    def put!(...) = put(...) || raise(Yuzakan::DB::Repo::NotFoundNameError, "Adapter not found: #{name}")

    def set!(name, class:)
      raise(Yuzakan::DB::Repo::DuplicateNameError, "Adapter already exists: #{name}") if @store[name]

      @store[name] = AdapterStruct.new(name:, class:)
    end

    def unset(name) = @store.delete(name)
    def unset!(...) = unset(...) || raise(Yuzakan::DB::Repo::NotFoundNameError, "Adapter not found: #{name}")

    def rename!(old_name, new_name)
      if old_name == new_name
        get!(old_name)
      elsif exist?(new_name)
        raise(Yuzakan::DB::Repo::DuplicateNameError, "Adapter already exists: #{new_name}")
      else
        get!(old_name).with(name: new_name).tap do |struct|
          @store.delete(old_name)
          @store[new_name] = struct
        end
      end
    end

    def exist?(name) = !@store[name].nil?
    def list = @store.compact.keys
  end
end
