require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Create do
  let(:action) {
    Api::Controllers::Attrs::Create.new(**action_opts, attr_repository: attr_repository,
                                                       provider_repository: provider_repository)
  }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { attr_params }
  let(:attr_params) {
    {
      name: 'attr1', display_name: '属性①', type: 'string', order: 8, hidden: false,
      mappings: [
        {provider: 'provider1', name: 'attr1_1', conversion: nil},
        {provider: 'provider2', name: 'attr1_2', conversion: 'e2j'},
      ],
    }
  }
  let(:attr_attributes) {
    attr_mappings = attr_params[:mappings].map do |mapping|
      {**mapping.except(:provider), provider: {name: mapping[:provider]}}
    end
    {**attr_params.except(:mappings), attr_mappings: attr_mappings}
  }
  let(:attr_with_mappings) { Attr.new(id: 42, **attr_attributes) }
  let(:attr_repository) {
    AttrRepository.new.tap do |obj|
      stub(obj).exist_by_name? { false }
      stub(obj).last_order { 16 }
      stub(obj).create_with_mappings { attr_with_mappings }
    end
  }
  let(:providers) { [Provider.new(id: 3, name: 'provider1'), Provider.new(id: 7, name: 'provider2')] }
  let(:provider_repository) { ProviderRepository.new.tap { |obj| stub(obj).all { providers } } }

  it 'is failure' do
    response = action.call(params)
    _(response[0]).must_equal 403
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({code: 403, message: 'Forbidden'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(response[1]['Location']).must_equal "/api/attrs/#{attr_with_mappings.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({**attr_params, label: attr_attributes[:display_name]})
    end

    it 'is successful without order param' do
      response = action.call(params.except(:order))
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(response[1]['Location']).must_equal "/api/attrs/#{attr_with_mappings.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({**attr_params, label: attr_attributes[:display_name]})
    end

    it 'is failure with bad name pattern' do
      response = action.call({**params, name: '!'})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['名前付けの規則に違反しています。']}],
      })
    end

    it 'is failure with name over' do
      response = action.call({**params, name: 'a' * 256})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['サイズが255を超えてはいけません。']}],
      })
    end

    it 'is failure with name over' do
      response = action.call({**params, name: 1})
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['文字列を入力してください。']}],
      })
    end

    it 'is failure with bad mapping params' do
      response = action.call({
        **params,
        mappings: [
          {provider: '', name: 'attr1_1', conversion: nil},
          {name: 'attr1_2', conversion: 'e2j'},
        ],
      })
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{
          mappings: {
            '0': {provider: ['入力が必須です。']},
            '1': {provider: ['存在しません。']},
          },
        }],
      })
    end

    it 'is failure without params' do
      response = action.call(env)
      _(response[0]).must_equal 400
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        code: 400,
        message: 'Bad Request',
        errors: [{name: ['存在しません。'], type: ['存在しません。']}],
      })
    end

    describe 'existed name' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { false }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 16 }
          stub(obj).create_with_mappings { attr_with_mappings }
        end
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。']}],
        })
      end

      it 'is failure with bad name pattern' do
        response = action.call({**params, name: '!'})
        _(response[0]).must_equal 400
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 400,
          message: 'Bad Request',
          errors: [{name: ['名前付けの規則に違反しています。']}],
        })
      end
    end

    describe 'not found provider' do
      let(:providers) { [Provider.new(id: 3, name: 'provider1')] }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{mappings: {'1': {provider: ['見つかりません。']}}}],
        })
      end
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
