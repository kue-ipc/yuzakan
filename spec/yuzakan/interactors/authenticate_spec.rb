# frozen_string_literal: true

require_relative '../../spec_helper'

describe Authenticate do
  let(:interactor) { Authenticate.new }
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
      _(result.failure?).must_equal true
    end
  end

  it 'call successful' do
    result = interactor.call(params)
    _(result.successful?).must_equal true
  end
end
