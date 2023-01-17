# frozen_string_literal: true

RSpec.describe Api::Controllers::Attrs::Update, type: :action do
  init_controller_spec(self)
  let(:action) {
    Api::Controllers::Attrs::Update.new(**action_opts, attr_repository: attr_repository,
                                                       attr_mapping_repository: attr_mapping_repository,
                                                       provider_repository: provider_repository)
  }
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'attr1', **attr_params} }
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
  let(:attr_without_mappings) { Attr.new(id: 42, **attr_attributes.except(:attr_mappings)) }
  let(:attr_with_mappings) { Attr.new(id: 42, **attr_attributes) }
  let(:attr_repository) {
    AttrRepository.new.tap do |obj|
      stub(obj).find_with_mappings_by_name { attr_with_mappings }
      stub(obj).find_with_mappings { attr_with_mappings }
      stub(obj).exist_by_name? { false }
      stub(obj).update { attr_without_mappings }
      stub(obj).add_mapping { AttrMapping.new }
      stub(obj).remove_mapping { AttrMapping.new }
    end
  }
  let(:attr_mapping_repository) { AttrMappingRepository.new.tap { |obj| stub(obj).update { AttrMapping.new } } }
  let(:providers) { [Provider.new(id: 3, name: 'provider1'), Provider.new(id: 7, name: 'provider2')] }
  let(:provider_repository) { ProviderRepository.new.tap { |obj| stub(obj).all { providers } } }

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).to eq 403
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({code: 403, message: 'Forbidden'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({**attr_params, label: attr_attributes[:display_name]})
    end

    it 'is successful with different' do
      response = action.call({**params, name: 'hoge', label: 'ほげ'})
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({**attr_params, label: attr_attributes[:display_name]})
    end

    describe 'not existed' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).find_with_mappings_by_name { nil }
          stub(obj).find_with_mappings { nil }
          stub(obj).exist_by_name? { false }
          stub(obj).update { attr_without_mappings }
          stub(obj).delete_mapping_by_provider_id { 1 }
          stub(obj).add_mapping { AttrMapping.new }
        end
      }

      it 'is failure' do
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

    describe 'existed name' do
      let(:attr_repository) {
        AttrRepository.new.tap do |obj|
          stub(obj).find_with_mappings_by_name { attr_with_mappings }
          stub(obj).find_with_mappings { attr_with_mappings }
          stub(obj).exist_by_name? { true }
          stub(obj).update { attr_without_mappings }
          stub(obj).delete_mapping_by_provider_id { 1 }
          stub(obj).add_mapping { AttrMapping.new }
        end
      }

      it 'is successful' do
        response = action.call(params)
        expect(response[0]).to eq 200
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({**attr_params, label: attr_attributes[:display_name]})
      end

      it 'is successful with diffrent only label' do
        response = action.call({**params, labal: 'ほげ'})
        expect(response[0]).to eq 200
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({**attr_params, label: attr_attributes[:display_name]})
      end

      it 'is failure with different' do
        response = action.call({**params, name: 'hoge', label: 'ほげ'})
        expect(response[0]).to eq 422
        expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: 'Unprocessable Entity',
          errors: [{name: ['重複しています。']}],
        })
      end
    end
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
