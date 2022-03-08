require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Update do
  let(:action) {
    Api::Controllers::Attrs::Update.new(activity_log_repository: activity_log_repository,
                                        config_repository: config_repository,
                                        user_repository: user_repository,
                                        attr_repository: attr_repository,
                                        attr_mapping_repository: attr_mapping_repository,
                                        provider_repository: provider_repository)
  }
  let(:params) { {**env, id: 'attr1', **attr_params} }

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
      name: 'attr1', label: '属性①', type: 'string', order: 8, hidden: false,
      attr_mappings: [
        {name: 'attr1_1', conversion: nil, provider: {name: 'provider1'}},
        {name: 'attr1_2', conversion: 'e2j', provider: {name: 'provider2'}},
      ],
    }
  }
  let(:attr_without_mappings) { Attr.new(id: 42, **attr_params.except(:attr_mappings)) }
  let(:attr_with_mappings) { Attr.new(id: 42, **attr_params) }
  let(:attr_repository) {
    AttrRepository.new.tap do |obj|
      stub(obj).find_with_mappings_by_name { attr_with_mappings }
      stub(obj).find_with_mappings { attr_with_mappings }
      stub(obj).exist_by_name? { false }
      stub(obj).exist_by_label? { false }
      stub(obj).exist_by_order? { false }
      stub(obj).update { attr_without_mappings }
      stub(obj).delete_mapping_by_provider_id { 1 }
      stub(obj).add_mapping { AttrMapping.new }
    end
  }
  let(:attr_mapping_repository) { AttrMappingRepository.new.tap { |obj| stub(obj).update { AttrMapping.new } } }
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
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal(attr_params)
    end

    it 'is successful with different' do
      response = action.call({**params, name: 'hoge', label: 'ほげ'})
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal(attr_params)
    end

    describe 'not existed' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).find_with_mappings_by_name { nil }
          stub(obj).find_with_mappings { nil }
          stub(obj).exist_by_name? { false }
          stub(obj).exist_by_label? { false }
          stub(obj).exist_by_order? { false }
          stub(obj).update { attr_without_mappings }
          stub(obj).delete_mapping_by_provider_id { 1 }
          stub(obj).add_mapping { AttrMapping.new }
        end
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 404
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 404,
          message: 'Not Found',
        })
      end
    end

    describe 'existed name' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).find_with_mappings_by_name { attr_with_mappings }
          stub(obj).find_with_mappings { attr_with_mappings }
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { false }
          stub(obj).exist_by_order? { false }
          stub(obj).update { attr_without_mappings }
          stub(obj).delete_mapping_by_provider_id { 1 }
          stub(obj).add_mapping { AttrMapping.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(attr_params)
      end

      it 'is successful with diffrent only label' do
        response = action.call({**params, labal: 'ほげ'})
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(attr_params)
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
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
          stub(obj).find_with_mappings_by_name { attr_with_mappings }
          stub(obj).find_with_mappings { attr_with_mappings }
          stub(obj).exist_by_name? { false }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).update { attr_without_mappings }
          stub(obj).delete_mapping_by_provider_id { 1 }
          stub(obj).add_mapping { AttrMapping.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(attr_params)
      end

      it 'is successful with diffrent only name' do
        response = action.call({**params, name: 'hoge'})
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(attr_params)
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
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
          stub(obj).find_with_mappings_by_name { attr_with_mappings }
          stub(obj).find_with_mappings { attr_with_mappings }
          stub(obj).exist_by_name? { true }
          stub(obj).exist_by_label? { true }
          stub(obj).exist_by_order? { false }
          stub(obj).update { attr_without_mappings }
          stub(obj).delete_mapping_by_provider_id { 1 }
          stub(obj).add_mapping { AttrMapping.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(attr_params)
      end

      it 'is successful with diffrent only hidden' do
        response = action.call({**params, hidden: 'true'})
        _(response[0]).must_equal 200
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal(attr_params)
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
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
