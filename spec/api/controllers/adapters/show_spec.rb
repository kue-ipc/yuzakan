# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Api::Controllers::Adapters::Show do
  let(:action) { Api::Controllers::Adapters::Show.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'dummy'} }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({name: 'dummy', label: 'ダミー'})
  end

  it 'is successful with test adapter' do
    response = action.call({**params, id: 'test'})
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({name: 'test', label: 'テスト'})
  end

  it 'is failure with unknown id' do
    response = action.call({**params, id: 'hoge'})
    _(response[0]).must_equal 404
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({code: 404, message: 'Not Found'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({name: 'dummy', label: 'ダミー', param_types: []})
    end

    it 'is successful with test adapter' do
      response = action.call({**params, id: 'test'})
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        name: 'test',
        label: 'テスト',
        param_types: [
          {name: 'default', label: 'default', description: nil, type: 'string', default: nil, fixed: false,
           encrypted: false, input: 'text', list: nil, required: true, placeholder: nil,},
          {name: 'str', label: '文字列', description: '詳細', type: 'string', default: nil, fixed: false,
           encrypted: false, input: 'text', list: nil, required: true, placeholder: 'プレースホルダー',},
          {name: 'str_default', label: 'デフォルト値', description: nil, type: 'string', default: 'デフォルト', fixed: false, encrypted: false, input: 'text', list: nil, required: false, placeholder: 'デフォルト'},
          {name: 'str_fixed', label: '固定値', description: nil, type: 'string', default: '固定', fixed: true,
           encrypted: false, input: 'text', list: nil, required: false, placeholder: '固定',},
          {name: 'str_required', label: '必須文字列', description: nil, type: 'string', default: nil, fixed: false,
           encrypted: false, input: 'text', list: nil, required: true, placeholder: nil,},
          {name: 'str_enc', label: '暗号文字列', description: nil, type: 'string', default: nil, fixed: false,
           encrypted: true, input: 'text', list: nil, required: true, placeholder: nil,},
          {name: 'text', label: 'テキスト', description: nil, type: 'text', default: nil, fixed: false,
           encrypted: false, input: 'textarea', list: nil, required: true, placeholder: nil,},
          {name: 'int', label: '整数', description: nil, type: 'integer', default: nil, fixed: false,
           encrypted: false, input: 'number', list: nil, required: true, placeholder: nil,},
          {name: 'list', label: 'リスト', description: nil, type: 'string', default: 'default', fixed: false,
           encrypted: false, input: 'text', list: [
             {name: 'default', label: 'デフォルト', value: 'default', deprecated: false},
             {name: 'other', label: 'その他', value: 'other', deprecated: false},
             {name: 'deprecated', label: '非推奨', value: 'deprecated', deprecated: true},
           ], required: false, placeholder: 'default',},
        ],
      })
    end

    it 'is failure with unknown id' do
      response = action.call({**params, id: 'hoge'})
      _(response[0]).must_equal 404
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({code: 404, message: 'Not Found'})
    end
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({code: 401, message: 'Unauthorized'})
    end
  end
end
