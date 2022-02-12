require_relative '../../spec_helper'

describe InitialSetup do
  let(:interactor) { InitialSetup.new }
  let(:params) {
    {config: {
      title: 'テスト',
    },
     admin_user: {
       username: 'admin',
       password: 'pass',
       password_confirmation: 'pass',
     },}
  }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'call successful' do
      result = interactor.call(params)
      _(result.successful?).must_equal true
    end
  end

  it 'reject after initialized' do
    result = interactor.call(params)
    _(result.successful?).must_equal false
  end
end
