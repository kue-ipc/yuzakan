# frozen_string_literal: true

require 'yaml'

RSpec.describe Api::Controllers::Myself::Show, type: :action do
  init_controller_spec
  let(:action) { Api::Controllers::Myself::Show.new(**action_opts, provider_repository: provider_repository) }
  let(:format) { 'application/json' }

  let(:providers) {
    [create_mock_provider(
      name: 'provider',
      params: {
        username: 'user', display_name: 'ユーザー', email: 'user@example.jp',
        primary_group: 'group',
        groups: 'admin, staff',
        attrs: YAML.dump({'jaDisplayName' => '表示ユーザー'}),
      },
      attr_mappings: [{
        name: 'jaDisplayName', conversion: nil,
        attr: {name: 'ja_display_name', display_name: '日本語表示名', type: 'string', hidden: false},
      }])]
  }
  let(:provider_repository) { instance_double('ProviderRepository', ordered_all_with_adapter_by_operation: providers) }
  let(:user_with_groups) {
    User.new(**user.to_h,
      members: [
        Member.new(primary: true, group: Group.new(groupname: 'group')),
        Member.new(primary: false, group: Group.new(groupname: 'admin')),
        Member.new(primary: false, group: Group.new(groupname: 'staff')),
      ])
  }

  it 'is successful' do
    allow(user_repository).to receive(:find_by_username).and_return(user)
    allow(user_repository).to receive(:update).and_return(user)
    allow(user_repository).to receive(:find_with_groups).and_return(user_with_groups)

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
      primary_group: 'group',
      groups: ['group', 'admin', 'staff'],
      userdata: {
        username: 'user',
        display_name: 'ユーザー',
        email: 'user@example.jp',
        primary_group: 'group',
        groups: [],
        attrs: {ja_display_name: '表示ユーザー'},
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
          primary_group: 'group',
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
