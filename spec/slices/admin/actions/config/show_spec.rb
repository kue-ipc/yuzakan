# frozen_string_literal: true

RSpec.describe Admin::Actions::Config::Show do
  init_action_spec

  it "is failure" do
    response = action.call(params)
    expect(response).to be_client_error
    expect(response.status).to eq 403
  end

  context "when admin" do
    let(:user) { create_struct(:user, :superuser) }

    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
    end
  end
end
