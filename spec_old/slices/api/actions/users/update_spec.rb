# frozen_string_literal: true

RSpec.describe API::Actions::Users::Update do
  init_controller_spec
  let(:format) { "application/json" }
  let(:action_opts) {
    {
      config_repository: config_repository,
      provider_repository: provider_repository,
      user_repository: user_repository,
      group_repository: group_repository,
      member_repository: member_repository,
    }
  }
  let(:action_params) {
    {
      id: "user",
      **user_attributes.except(:id),
      primary_group: primary_group.name,
      groups: groups.map(&:name),
      attrs: user_attrs,
      providers: providers.map(&:name),
    }
  }

  it "is failure" do
    response = action.call(params)
    expect(response[0]).to eq 403
    expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({code: 403, message: "Forbidden"})
  end

  # describe 'admin' do
  #   let(:user) { User.new(**user_attributes, clearance_level: 5) }
  #   let(:client) { '127.0.0.1' }

  #   it 'is successful' do
  #     allow(provider_repository).to receive(:ordered_all_with_adapter_by_operation).and_return([])

  #     response = action.call(params)
  #     expect(response[0]).to eq 200
  #     expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
  #     json = JSON.parse(response[2].first, symbolize_names: true)
  #     expect(json).to eq({
  #       **user_attributes.except(:id)
  #     })
  #   end
  # end
end
