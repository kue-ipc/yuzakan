require_relative '../../../spec_helper'

describe Api::Controllers::Session::Destroy do
  let(:action) { Api::Controllers::Session::Destroy.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }

  it 'is successful' do
    begin_time = Time.now.floor
    response = action.call(params)
    end_time = Time.now.floor
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json[:uuid]).must_match uuid
    _(json[:current_user]).must_equal({**user.to_h.except(:id), label: user.label})
    created_at = Time.iso8601(json[:created_at])
    _(created_at).must_equal session[:created_at].floor
    updated_at = Time.iso8601(json[:updated_at])
    _(updated_at).must_be :>=, begin_time
    _(updated_at).must_be :<=, end_time
    deleted_at = Time.iso8601(json[:deleted_at])
    _(deleted_at).must_be :>=, begin_time
    _(deleted_at).must_be :<=, end_time
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 410
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 410,
        message: 'Gone',
      })
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 410
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 410,
        message: 'Gone',
      })
    end
  end

  describe 'session timeout' do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 401,
        message: 'Unauthorized',
        errors: ['セッションがタイムアウトしました。'],
      })
    end
  end
end
