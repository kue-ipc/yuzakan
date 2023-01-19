# frozen_string_literal: true

RSpec.describe Admin::Controllers::Providers::Show, type: :action do
  init_controller_spec
  let(:action_opts) { {provider_repository: provider_repository} }
  let(:action_params) { {id: 'provider1'} }
  let(:provider_repository_stubs) { {exist_by_name?: true} }

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).to eq 403
  end

  describe 'admin' do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { '127.0.0.1' }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
    end

    it 'is successful with * for new' do
      response = action.call({**params, id: '*'})
      expect(response[0]).to eq 200
    end

    it 'is failure with !' do
      response = action.call({**params, id: '!'})
      expect(response[0]).to eq 400
    end

    describe 'not existed' do
      let(:provider_repository_stubs) { {exist_by_name?: false} }

      it 'is failure' do
        response = action.call(params)
        expect(response[0]).to eq 404
      end
    end
  end

  describe 'redirect no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/'
    end
  end
end
