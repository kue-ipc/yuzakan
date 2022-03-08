require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Create do
  let(:action) {
    Api::Controllers::Attrs::Create.new(activity_log_repository: activity_log_repository,
                                        config_repository: config_repository,
                                        user_repository: user_repository,
                                        attr_repository: attr_repository,
                                        provider_repository: provider_repository)
  }
  let(:params) { {**env, **attr_params} }

  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  let(:attr_params) {
    {
      name: 'attr1', label: '属性①', type: 'string', hidden: false, order: 8,
      attr_mappings: [
        {name: 'attr1_1', conversion: nil, provider: {name: 'provider1'}},
        {name: 'attr1_2', conversion: 'e2j', provider: {name: 'provider2'}},
      ],
    }
  }
  let(:attr_with_mappings) { Attr.new(id: 42, **attr_params) }
  let(:attr_repository) {
    AttrRepository.new.tap do |obj|
      stub(obj).exist_by_name? { false }
      stub(obj).exist_by_label? { false }
      stub(obj).exist_by_order? { false }
      stub(obj).last_order { 16 }
      stub(obj).create_with_mappings { attr_with_mappings }
    end
  }
  let(:providers) {
    [
      Provider.new(id: 3, name: 'provider1'),
      Provider.new(id: 7, name: 'provider2'),
    ]
  }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).all { providers } }
  }

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
      _(json).must_equal(attr_params)
    end

    it 'is successful without order param' do
      response = action.call(params.except(:order))
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      _(response[1]['Location']).must_equal "/api/attrs/#{attr_with_mappings.id}"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal(attr_params)
    end

    describe 'bad params' do
      let(:attr_params) {
        {
          name: '', label: '属性①', type: 'string', hidden: false,
          attr_mappings: [
            {name: 'attr1_1', conversion: nil, provider: {name: ''}},
            {name: 'attr1_2', conversion: 'e2j'},
          ],
        }
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{
            name: ['入力が必須です。'],
            attr_mappings: {
              '0': {provider: {name: ['入力が必須です。']}},
              '1': {provider: ['存在しません。']},
            },
          }],
        })
      end

      describe 'existed name' do
        let(:attr_repository) {
          AttrRepository.new.tap do |obj|
            stub(obj).exist_by_name? { true }
            stub(obj).exist_by_label? { false }
            stub(obj).exist_by_order? { false }
            stub(obj).last_order { 6 }
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
            errors: [{
              name: ['入力が必須です。'],
              attr_mappings: {
                '0': {provider: {name: ['入力が必須です。']}},
                '1': {provider: ['存在しません。']},
              },
            }],
          })
        end
      end

      describe 'existed label' do
        let(:attr_repository) {
          AttrRepository.new.tap do |obj|
            stub(obj).exist_by_name? { false }
            stub(obj).exist_by_label? { true }
            stub(obj).exist_by_order? { false }
            stub(obj).last_order { 6 }
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
            errors: [{
              name: ['入力が必須です。'],
              label: ['重複しています。'],
              attr_mappings: {
                '0': {provider: {name: ['入力が必須です。']}},
                '1': {provider: ['存在しません。']},
              },
            }],
          })
        end
      end
    end

    describe 'no params' do
      let(:attr_params) { {} }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 422
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['存在しません。'], label: ['存在しません。'], type: ['存在しません。']}],
        })
      end
    end

    describe 'existed name' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { false }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 6 }
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
    end

    describe 'existed label' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).exist_by_name? { false }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 6 }
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
          errors: [{label: ['重複しています。']}],
        })
      end
    end

    describe 'existed name nad label' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).last_order { 6 }
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
          errors: [{name: ['重複しています。'], label: ['重複しています。']}],
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
          errors: [{attr_mappings: {'1': {provider: {name: ['見つかりません。']}}}}],
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
