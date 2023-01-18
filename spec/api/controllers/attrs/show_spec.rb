# frozen_string_literal: true

RSpec.describe Api::Controllers::Attrs::Show, type: :action do
  init_controller_spec
  let(:action_opts) { {attr_repository: attr_repository} }
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'attr1'} }
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
  let(:attr_repository) { instance_double('AttrRepository', find_with_mappings_by_name: attr_with_mappings) }

  it 'is successful' do
    response = action.call(params)
    expect(response[0]).to eq 200
    expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({**attr_params.except(:mappings), label: attr_attributes[:display_name]})
  end

  describe 'monitor' do
    let(:user) {
      User.new(id: 1, name: 'monitor', display_name: '監視者', email: 'monitor@example.jp', clearance_level: 2)
    }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({**attr_params, label: attr_attributes[:display_name]})
    end
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

    describe 'not existed' do
      let(:attr_repository) { instance_double('AttrRepository', find_with_mappings_by_name: nil) }

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
