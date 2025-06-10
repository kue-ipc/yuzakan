# frozen_string_literal: true

RSpec.describe "PATCH /api/users/:id/password", :db, type: :request do
  init_request_spec

  let(:request_headers) {
    {
      "HTTP_ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json",
    }
  }
  let(:params) {
    {
      password_current: password,
      password: new_password,
      password_confirmation: new_password,
    }
  }
  let(:new_password) { "new_password" }

  it "is updated" do
    patch "/api/users/~/password", params.to_json, request_headers
    # warn last_response.body
    expect(last_response).to be_ok
    expect(last_response.status).to eq 200
    expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(last_response.body, symbolize_names: true)
    expect(json).to eq({
      status: {code: 200, message: "OK"},
      location: "/api/users/~/password",
      flash: {success: "パスワード変更に成功しました。"},
      data: {password: new_password, providers: ["mock"]},
    })
  end
end
