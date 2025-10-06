# frozen_string_literal: true

RSpec.describe API::Actions::Auth::Show do
  init_action_spec

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({username: user.name})
    end
  end

  shared_examples "not found" do
    it "is not found" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({error: "ログインしていません。"})
    end
  end

  it_behaves_like "ok"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "ok"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok"
  end

  context "when logout" do
    include_context "when logout"
    it_behaves_like "not found"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "not found"
  end

  context "when timeover" do
    include_context "when timeover"

    it "is failure" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({error: "ログインしていません。", warn: "セッションがタイムアウトしました。"})
    end
  end
end
