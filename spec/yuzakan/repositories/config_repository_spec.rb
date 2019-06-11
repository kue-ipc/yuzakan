# frozen_string_literal: true

require_relative '../../spec_helper'

describe ConfigRepository do
  # place your tests here

  before do
    db_clear
    db_initialize
  end

  it 'current is nil before initialized' do
    db_clear
    ConfigRepository.new.current.must_be_nil
  end

  it 'current is config after initialized' do
    ConfigRepository.new.current.wont_be_nil
  end

  it 'initialized? is false before initialized' do
    db_clear
    ConfigRepository.new.initialized?.must_equal false
  end

  it 'initialized? is true after initialized' do
    ConfigRepository.new.initialized?.must_equal true
  end
end
