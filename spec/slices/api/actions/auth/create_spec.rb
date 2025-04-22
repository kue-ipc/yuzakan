# frozen_string_literal: true

RSpec.describe API::Actions::Auth::Create do
  init_action_spec

  let(:action_opts) {
    {
      auth_log_repo: auth_log_repo,
      user_repo: user_repo,
      sync_user: sync_user,
      authenticate: authenticate,
    }
  }
  let(:action_params) { {username: user.name, password: password} }
  let(:password) { Faker::Internet.password }

  let(:auth_log_repo) {
    instance_double(Yuzakan::Repos::AuthLogRepo, create: auth_log, recent: [])
  }

  let(:sync_user) {
    instance_double(Yuzakan::Management::SyncUser, call: Success(user))
  }
  let(:authenticate) {
    instance_double(Yuzakan::Providers::Authenticate, call: Success(provider))
  }

  it "is redirection (see other)" do
    response = action.call(params)
    expect(response).to be_redirection
    expect(response.status).to eq 303
    expect(response.headers["Location"]).to eq "/api/auth"
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:location]).to eq "/api/auth"
  end

  context "when no login" do
    let(:session) { logout_session }

    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({username: user.name})
    end

    it "is failed without username" do
      response = action.call(params.except(:username))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {username: ["存在しません。"]}})
    end

    it "is failed with empty username" do
      response = action.call({**params, username: ""})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {username: ["入力が必須です。"]}})
    end

    it "is failed with invalid username" do
      response = action.call({**params, username: "#{user.name}!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {username: ["形式が間違っています。"]}})
    end

    it "is failed with too long username" do
      response = action.call({**params, username: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {username: ["サイズが255を超えてはいけません。"]}})
    end

    it "is failed without password" do
      response = action.call(params.except(:password))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {password: ["存在しません。"]}})
    end

    it "is failed with empty password" do
      response = action.call({**params, password: ""})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {password: ["入力が必須です。"]}})
    end

    it "is failed with too long password" do
      response = action.call({**params, password: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {password: ["サイズが255を超えてはいけません。"]}})
    end

    it "is failed without both username and password" do
      response = action.call(params.except(:username, :password))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {username: ["存在しません。"], password: ["存在しません。"]}})
    end

    describe "authentication failure" do
      let(:authenticate) {
        instance_double(Yuzakan::Providers::Authenticate,
          call: Failure([:failure, error_message]))
      }
      let(:error_message) { Faker::Lorem.paragraph }

      it "is failed" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({failure: error_message})
      end
    end

    describe "too many access" do
      let(:auth_log_repo) {
        instance_double(Yuzakan::Repos::AuthLogRepo, create: auth_log, recent: [
          Factory.structs[:auth_log_failure],
          Factory.structs[:auth_log_failure],
          Factory.structs[:auth_log_failure],
          Factory.structs[:auth_log_failure],
          Factory.structs[:auth_log_failure],
        ])
      }

      it "is failure" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 403
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({
          error: "時間あたりのログイン試行が規定の回数を超えたため、現在ログインが禁止されています。 " \
                 "しばらく待ってから再度ログインを試してください。",
        })
      end
    end

    describe "untrusted network" do
      let(:network) { Factory.structs[:network, trusted: false, clearance_level: 5] }

      it "is failure" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 403
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({error: "現在のネットワークからのログインは許可されていません。"})
      end
    end
  end

  context "when no session" do
    let(:session) { {} }

    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({username: user.name})
    end
  end
end
