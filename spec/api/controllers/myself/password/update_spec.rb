# frozen_string_literal: true

require_relative '../../../../spec_helper'

RSpec.describe Api::Controllers::Myself::Password::Update do
  let(:action) {
    Api::Controllers::Myself::Password::Update.new(**action_opts, provider_repository: provider_repository,
                                                                  user_notify: user_notify)
  }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {current_password: 'pass', password: 'word', password_confirmation: 'word'} }

  let(:providers) { [create_mock_provider(params: {username: 'user', password: 'pass'})] }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).ordered_all_with_adapter_by_operation { providers } }
  }
  let(:user_notify) { Object.new.tap { |obj| stub(obj).deliver } }

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).must_equal 200
    expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).must_equal({password: {size: 4, types: 1, score: 0}})
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).must_equal 401
      expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).must_equal({
        code: 401,
        message: 'Unauthorized',
      })
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).must_equal 401
      expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).must_equal({
        code: 401,
        message: 'Unauthorized',
      })
    end
  end

  describe 'session timeout' do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).must_equal 401
      expect(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).must_equal({
        code: 401,
        message: 'Unauthorized',
        errors: ['セッションがタイムアウトしました。'],
      })
    end
  end
end
