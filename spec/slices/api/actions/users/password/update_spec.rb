# frozen_string_literal: true

RSpec.describe API::Actions::Users::Password::Update do
  init_action_spec

  let(:action_params) {
    {
      id: id,
      password_current: current_password,
      password: new_password,
      password_confirmation: new_password,
    }
  }
  # let(:action_opts) {
  #   allow(config_repo).to receive(:set).and_return(updated_config)
  #   {
  #     config_repo: config_repo,
  #   }
  # }
  let(:id) { "~" }
  let(:new_password) { "new_password" }
  let(:current_password) { "current_password" }

  it "is successful" do
    response = action.call(params)
    expect(response).to be_successful
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:data]).to eq({
      password: new_password,
    })
  end

  it "is failed without user id" do
    response = action.call(params.except(:id))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {id: ["存在しません。"]}})
  end

  it "is failed without current password" do
    response = action.call(params.except(:password_current))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {password_current: ["存在しません。"]}})
  end

  it "is failed without new password" do
    response = action.call(params.except(:password))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {password: ["存在しません。"]}})
  end

  it "is failed without confirm password" do
    response = action.call(params.except(:password_confirmation))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {password_confirmation: ["存在しません。"]}})
  end

  it "is failed without all passwords" do
    response = action.call(params.except(:password_current, :password, :password_confirmation))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {
      password_current: ["存在しません。"],
      password: ["存在しません。"],
      password_confirmation: ["存在しません。"],
    }})
  end

  it "is failed with different password confirmation" do
    response = action.call(params.merge(password_confirmation: "different_password"))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {password_confirmation: ["新しいパスワードと値が一致しません。"]}})
  end

  it "is failed with wrong user id" do
    response = action.call(**params, id: "wrong_id")
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {id: ["~と値が一致しません。"]}})
  end

  describe "" do
    let(:current_password) { "あ" }
    let(:new_password) { "い" }

    it "is failed with all wrong passwords" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {
        password_current: ["形式が間違っています。"],
        password: ["形式が間違っています。"],
        password_confirmation: ["形式が間違っています。"],
      }})
    end
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
