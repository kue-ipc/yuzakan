# frozen_string_literal: true

RSpec.describe API::Actions::Auth::Mfa::Create do
  init_action_spec

  let(:action_opts) {
    {
      user_repo: user_repo,
    }
  }
  let(:action_params) { {code: code} }
  let(:code) { fake(:internet, :password) }

  shared_examples "created" do
    it "is created" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({username: user.name})
    end
  end

  shared_examples "redirection" do
    it "is redirection" do
      response = action.call(params)
      expect(response).to be_redirection
      expect(response.status).to eq 303
      expect(response.headers["Location"]).to eq "/api/auth"
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/auth"
    end
  end

  it_behaves_like "redirection"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "redirection"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "redirection"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "redirection"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "redirection"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "redirection"
  end

  context "when logout" do
    include_context "when logout"

    it_behaves_like "created"

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
        instance_double(Yuzakan::Services::Authenticate, call: Failure([:failure, failure_message]))
      }
      let(:failure_message) { { fake(:lorem, :paragaph) } }

      it "is failed" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({failure: failure_message})
      end
    end

    describe "too many access" do
      let(:auth_log_repo) {
        # TODO: 何か
        instance_double(Yuzakan::Repos::AuthLogRepo, create: auth_log, recent: [
          Factory.structs[:failure_auth_log],
          Factory.structs[:failure_auth_log],
          Factory.structs[:failure_auth_log],
          Factory.structs[:failure_auth_log],
          Factory.structs[:failure_auth_log],
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

  context "when first" do
    include_context "when first"
    it_behaves_like "created"
  end
end
