# frozen_string_literal: true

RSpec.describe Admin::Actions::Config::New do
  init_controller_spec

  it "rediret to root" do
    response = action.call(params)
    expect(response.status).to eq 302
    expect(response.headers["Location"]).to eq "/"
  end

  describe "before initialized" do
    let(:config_repository_stubs) { {current: nil} }

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 200
    end
  end
end
