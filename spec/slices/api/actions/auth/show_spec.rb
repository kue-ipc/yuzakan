# frozen_string_literal: true

RSpec.describe API::Actions::Auth::Show do
  init_action_spec

  it "is successful" do
    response = action.call(params)
    expect(response).to be_successful
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:data]).to eq({username: user.name})
  end

  context "when no login" do
    let(:session) { no_login_session }

    it "is failure" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({error: "ログインしていません。"})
    end
  end

  context "when no session" do
    let(:session) { {} }

    it "is failure" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({error: "ログインしていません。"})
    end
  end

  describe "session timeout" do
    let(:session) { timeout_session }

    it "is failure" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({error: "ログインしていません。"})
    end
  end
end
