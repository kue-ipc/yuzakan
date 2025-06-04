# frozen_string_literal: true

RSpec.describe API::Actions::Users::Password::Update do
  init_action_spec

  let(:action_params) {
    {
      current: current_password,
      new: new_password,
      confirm: new_password,
    }
  }
  # let(:action_opts) {
  #   allow(config_repo).to receive(:set).and_return(updated_config)
  #   {
  #     config_repo: config_repo,
  #   }
  # }
  let(:new_password) { "new_password" }
  let(:current_password) { "current_password" }

  it "is successful" do
    response = action.call(params)
    expect(response).to be_successful
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:data]).to eq({
      new: new_password,
    })
  end

  # context "when admin" do
  #   let(:user) { create_struct(:user, :superuser) }

  #   it "is successful" do
  #     response = action.call(params)
  #     expect(response).to be_successful
  #     expect(response.status).to eq 200
  #     expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
  #     json = JSON.parse(response.body.first, symbolize_names: true)
  #     expect(json[:data]).to eq({
  #       new: new_password,
  #     })
  #   end
  # end
end
