# frozen_string_literal: true

RSpec.describe API::Actions::Session::Create do
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

  let(:format) { "application/json" }

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
    expect(response.headers["Location"]).to eq "/api/session"
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({
      status: 303,
      message: "See Other",
      location: "/api/session",
    })
  end

  context "when no login" do
    let(:session) { {uuid: uuid, user: nil} }

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json.keys).to contain_exactly(:uuid, :user, :created_at, :updated_at)
      expect(json[:uuid]).to eq uuid
      expect(json[:user]).to eq user.name
      expect(Time.iso8601(json[:created_at])).to be_between(begin_time.floor, end_time)
      expect(Time.iso8601(json[:updated_at])).to eq Time.iso8601(json[:created_at])
    end

    it "is failed without username" do
      response = action.call(params.except(:username))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{username: ["存在しません。"]}],
      })
    end

    it "is failed with empty username" do
      response = action.call({**params, username: ""})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{username: ["入力が必須です。"]}],
      })
    end

    it "is failed with invalid username" do
      response = action.call({**params, username: "#{user.name}!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{username: ["形式が間違っています。"]}],
      })
    end

    it "is failed with too long username" do
      response = action.call({**params, username: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{username: ["サイズが255を超えてはいけません。"]}],
      })
    end

    it "is failed without password" do
      response = action.call(params.except(:password))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{password: ["存在しません。"]}],
      })
    end

    it "is failed with empty password" do
      response = action.call({**params, password: ""})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{password: ["入力が必須です。"]}],
      })
    end

    it "is failed with too long password" do
      response = action.call({**params, password: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{password: ["サイズが255を超えてはいけません。"]}],
      })
    end

    it "is failed without both username and password" do
      response = action.call(params.except(:username, :password))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: [{username: ["存在しません。"], password: ["存在しません。"]}],
      })
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
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          status: 422,
          message: "Unprocessable Entity",
          errors: [error_message],
        })
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
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          status: 403,
          message: "Forbidden",
          errors: ["時間あたりのログイン試行が規定の回数を超えたため、現在ログインが禁止されています。 " \
                   "しばらく待ってから再度ログインを試してください。"],
        })
      end
    end

    describe "untrusted network" do
      let(:network) { Factory.structs[:network, trusted: false, clearance_level: 5] }

      it "is failure" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 403
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          status: 403,
          message: "Forbidden",
          errors: ["現在のネットワークからのログインは許可されていません。"],
        })
      end
    end
  end

  context "when no session" do
    let(:session) { {} }

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:uuid]).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(json[:user]).to eq(user.name)
      expect(Time.iso8601(json[:created_at])).to be_between(begin_time.floor, end_time)
      expect(Time.iso8601(json[:updated_at])).to eq Time.iso8601(json[:created_at])
    end
  end
end
