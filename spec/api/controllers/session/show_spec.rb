# frozen_string_literal: true

RSpec.describe Api::Controllers::Session::Show, type: :action do
  init_controller_spec
  let(:action) { Api::Controllers::Session::Show.new(**action_opts) }
  let(:format) { 'application/json' }

  it 'is successful' do
    begin_time = Time.now.floor
    response = action.call(params)
    end_time = Time.now.floor
    expect(response[0]).to eq 200
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json[:uuid]).to eq uuid
    expect(json[:current_user]).to eq({**user.to_h.except(:id), label: user.label})
    created_at = Time.iso8601(json[:created_at])
    expect(created_at).to eq session[:created_at].floor
    updated_at = Time.iso8601(json[:updated_at])
    expect(updated_at).to be >= begin_time
    expect(updated_at).to be <= end_time
    deleted_at = Time.iso8601(json[:deleted_at])
    expect(deleted_at).to be >= begin_time + 3600
    expect(deleted_at).to be <= end_time + 3600
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 404
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 404,
        message: 'Not Found',
      })
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 404
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 404,
        message: 'Not Found',
      })
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
