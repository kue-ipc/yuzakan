# frozen_string_literal: true

require_relative '../../spec_helper'

describe Login do
  let(:interactor) { Login.new }
  let(:params) { Hash[
    username: 'admin',
    password: 'pass',
  ] }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'call failure' do
      result = interactor.call(params)
      result.failure?.must_equal true
    end
  end

  it 'call successful' do
    result = interactor.call(params)
    result.successful?.must_equal true
  end
end
