# frozen_string_literal: true

require_relative '../../../spec_helper'
require 'yaml'

RSpec.describe Api::Controllers::Myself::Show do
  let(:action) { Api::Controllers::Myself::Show.new(**action_opts, provider_repository: provider_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }

  let(:providers) {
    [create_mock_provider(
      name: 'provider',
      params: {
        username: 'user', display_name: 'ユーザー', email: 'user@example.jp',
        attrs: YAML.dump({'jaDisplayName' => '表示ユーザー'}),
      },
      attr_mappings: [{
        name: 'jaDisplayName', conversion: nil,
        attr: {name: 'ja_display_name', display_name: '日本語表示名', type: 'string', hidden: false},
      }])]
  }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).ordered_all_with_adapter_by_operation { providers } }
  }

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).to eq 200
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({
      username: 'user',
      display_name: 'ユーザー',
      label: 'ユーザー',
      email: 'user@example.jp',
      note: nil,
      reserved: false,
      deleted: false,
      deleted_at: nil,
      clearance_level: 1,
      primary_group: nil,
      groups: [],
      userdata: {
        username: 'user',
        display_name: 'ユーザー',
        email: 'user@example.jp',
        attrs: {ja_display_name: '表示ユーザー'},
        groups: [],
      },
      provider_userdatas: [{
        provider: 'provider',
        userdata: {
          username: 'user',
          display_name: 'ユーザー',
          email: 'user@example.jp',
          locked: false,
          unmanageable: false,
          mfa: false,
          attrs: {ja_display_name: '表示ユーザー'},
        },
      }],
    })
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({code: 401, message: 'Unauthorized'})
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({code: 401, message: 'Unauthorized'})
    end
  end

  describe 'session timeout' do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 401,
        message: 'Unauthorized',
        errors: ['セッションがタイムアウトしました。'],
      })
    end
  end
end
