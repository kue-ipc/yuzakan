require_relative '../../spec_helper'

describe Authenticate do
  let(:interactor) { Authenticate.new(client: '::1', app: 'test') }
  let(:params) do
    Hash[
    username: 'admin',
    password: 'pass',
  ]
  end

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
