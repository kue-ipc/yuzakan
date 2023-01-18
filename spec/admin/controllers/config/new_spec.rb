# frozen_string_literal: true

RSpec.describe Admin::Controllers::Config::New, type: :action do
  init_controller_spec
  let(:action) { Admin::Controllers::Config::New.new(**action_opts) }

  it 'rediret to root' do
    response = action.call(params)
    expect(response[0]).to eq 302
    expect(response[1]['Location']).to eq '/'
  end

  describe 'before initialized' do
    let(:config_repository) { instance_double('ConfigRepository', current: nil) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end
end
