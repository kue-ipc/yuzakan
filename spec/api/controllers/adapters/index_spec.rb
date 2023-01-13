# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Api::Controllers::Adapters::Index do
  let(:action) { Api::Controllers::Adapters::Index.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).to eq 200
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq [
      {name: 'ad',          label: 'Active Directory'},
      {name: 'dummy',       label: 'ダミー'},
      {name: 'google',      label: 'Google Workspace'},
      {name: 'ldap',        label: 'LDAP'},
      {name: 'local',       label: 'ローカル'},
      {name: 'mock',        label: 'モック'},
      {name: 'posix_ldap',  label: 'Posix LDAP'},
      {name: 'samba_ldap',  label: 'Samba LDAP'},
      {name: 'test',        label: 'テスト'},
    ]
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
end
