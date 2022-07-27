require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Index do
  let(:action) { Api::Controllers::Attrs::Index.new(**action_opts, attr_repository: attr_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval
  let(:format) { 'application/json' }

  let(:all_attrs_attributes) {
    [
      {id: 42, name: 'attr42', label: '属性42', type: 'string', order: 8, hidden: false},
      {id: 24, name: 'attr24', label: '属性24', type: 'integer', order: 16, hidden: false},
      {id: 19, name: 'attr19', label: '属性19', type: 'boolean', order: 24, hidden: false},
      {id: 27, name: 'attr27', label: '属性27', type: 'string', order: 32, hidden: true},
    ]
  }
  let(:all_attrs) { all_attrs_attributes.map { |attributes| Attr.new(attributes) } }
  let(:attr_repository) { AttrRepository.new.tap { |obj| stub(obj).ordered_all { all_attrs } } }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal(all_attrs_attributes.map { |attrs| attrs.except(:id) })
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
