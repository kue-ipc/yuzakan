# frozen_string_literal: true

RSpec.describe Admin::Actions::Providers::Index do
  init_controller_spec

  it "is failure" do
    response = action.call(params)
    expect(response.status).to eq 403
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 200
    end
  end

  describe "redirect no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 302
      expect(response.headers["Location"]).to eq "/"
    end
  end
end
