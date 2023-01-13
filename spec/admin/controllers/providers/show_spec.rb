# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Controllers::Providers::Show do
  let(:action) { Admin::Controllers::Providers::Show.new(**action_opts, provider_repository: provider_repository) }
  eval(init_let_script) # rubocop:disable Security/Eval

  let(:action_params) { {id: 'provider1'} }
  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).exist_by_name?('provider1') { true } }
  }

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).must_equal 403
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).must_equal 200
    end

    it 'is successful with * for new' do
      response = action.call({**params, id: '*'})
      expect(response[0]).must_equal 200
    end

    it 'is failure with !' do
      response = action.call({**params, id: '!'})
      expect(response[0]).must_equal 400
    end

    describe 'not existed' do
      let(:provider_repository) {
        ProviderRepository.new.tap { |obj| mock(obj).exist_by_name?('provider1') { false } }
      }

      it 'is failure' do
        response = action.call(params)
        expect(response[0]).must_equal 404
      end
    end
  end

  describe 'redirect no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).must_equal 302
      expect(response[1]['Location']).must_equal '/'
    end
  end
end
