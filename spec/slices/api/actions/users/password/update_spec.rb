# frozen_string_literal: true

RSpec.describe API::Actions::Users::Password::Update do
  init_action_spec

  let(:action_opts) {
    {
      authenticate: authenticate,
      change_password: change_password,
    }
  }

  let(:action_params) {
    {
      id: id,
      password_current: current_password,
      password: new_password,
      password_confirmation: new_password,
    }
  }

  let(:authenticate) {
    instance_double(Yuzakan::Providers::Authenticate, call: Success(provider))
  }
  let(:change_password) {
    instance_double(Yuzakan::Providers::ChangePassword, call: Success([[provider]]))
  }

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
      providers: [provider.name],
    })
    expect(json[:flash]).to eq({
      success: "パスワード変更に成功しました。",
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

  it "is failed with wrong user id" do
    response = action.call(**params, id: "wrong_id")
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {id: ["~と値が一致しません。"]}})
  end

  it "is failed with all wrong passwords" do
    response = action.call(**params, password_current: "あ", password: "い", password_confirmation: "う")
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

  it "is failed with different password confirmation" do
    response = action.call(params.merge(password_confirmation: "different_password"))
    expect(response).to be_client_error
    expect(response.status).to eq 422
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {passwordConfirmation: ["新しいパスワードと値が一致しません。"]}})
  end

  describe "authentication failure" do
    let(:authenticate) {
      instance_double(Yuzakan::Providers::Authenticate, call: Failure([:failure, failure_message]))
    }
    let(:failure_message) { Faker::Lorem.paragraph }

    it "is failed" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {passwordCurrent: ["現在のパスワードと値が一致しません。"]}})
    end
  end

  describe "unchanged" do
    let(:change_password) {
      instance_double(Yuzakan::Providers::ChangePassword, call: Success([[]]))
    }

    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        password: new_password,
        providers: [],
      })
      expect(json[:flash]).to eq({
        warn: "どのサービスでもパスワード変更が実行されませんでした。",
      })
    end
  end

  describe "change failure" do
    let(:change_password) {
      instance_double(Yuzakan::Providers::ChangePassword, call: Failure([:error, error_message]))
    }
    let(:error_message) { Faker::Lorem.paragraph }

    it "is failed" do
      response = action.call(params)
      expect(response).to be_server_error
      expect(response.status).to eq 500
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({error: error_message})
    end
  end
end
