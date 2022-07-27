require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Show do
  let(:action) { Api::Controllers::Attrs::Show.new(**action_opts, attr_repository: attr_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }
  let(:action_params) { {id: 'attr1'} }

  let(:attr_params) {
    {
      name: 'attr1', label: '属性①', type: 'string', order: 8, hidden: false,
      attr_mappings: [
        {name: 'attr1_1', conversion: nil, provider: {name: 'provider1'}},
        {name: 'attr1_2', conversion: 'e2j', provider: {name: 'provider2'}},
      ],
    }
  }
  let(:attr_with_mappings) { Attr.new(id: 42, **attr_params) }
  let(:attr_repository) { AttrRepository.new.tap { |obj| stub(obj).find_with_mappings_by_name { attr_with_mappings } } }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal(attr_params.except(:attr_mappings))
  end

  describe 'monitor' do
    let(:user) {
      User.new(id: 1, name: 'monitor', display_name: '監視者', email: 'monitor@example.jp', clearance_level: 2)
    }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal(attr_params)
    end
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

    describe 'not existed' do
      let(:attr_repository) { AttrRepository.new.tap { |obj| stub(obj).find_with_mappings { nil } } }

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
