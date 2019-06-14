require_relative '../../../spec_helper'

describe Admin::Controllers::Session::New do
  let(:action) { Admin::Controllers::Session::New.new }
  let(:params) { Hash[] }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'redirect setup' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup'
    end
  end

  describe 'before initialized' do
    before do
      db_clear
    end
  end

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
