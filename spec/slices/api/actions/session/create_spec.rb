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
      expect(Time.iso8601(json[:created_at])).to be_between(begin_time, end_time)
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
        errors: {username: ["is missing"]},
      })
    end

    describe "authentication failure" do
      let(:authenticate) {
        instance_double(Yuzakan::Providers::Authenticate, call: Failure([:failure, "message"]))
      }

      it "is failed" do
        response = action.call(params)

        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: "Unprocessable Entity",
          errors: ["ユーザー名またはパスワードが違います。"],
        })
      end
    end

    it "is failed with bad password" do
      response = action.call(**params, password: "badpass")
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 422,
        message: "Unprocessable Entity",
        errors: ["ユーザー名またはパスワードが違います。"],
      })
    end

    it "is error with no username" do
      response = action.call(**params.except(:username))
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{username: ["存在しません。"]}],
      })
    end

    it "is error with no password" do
      response = action.call(**params.except(:password))
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{password: ["存在しません。"]}],
      })
    end

    it "is error with too large username" do
      response = action.call(**params, username: "user" * 64)
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{username: ["サイズが255を超えてはいけません。"]}],
      })
    end

    it "is error with empty password" do
      response = action.call(**params, password: "")
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{password: ["入力が必須です。"]}],
      })
    end

    describe "too many access" do
      let(:auth_log_repository) {
        instance_double(AuthLogRepository,
          create: AuthLog.new,
          recent_by_username: [
            AuthLog.new(result: "failure"),
            AuthLog.new(result: "failure"),
            AuthLog.new(result: "failure"),
            AuthLog.new(result: "failure"),
            AuthLog.new(result: "failure"),
          ])
      }

      it "is failure" do
        response = action.call(params)
        expect(response.status).to eq 403
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          code: 403,
          message: "Forbidden",
          errors: ["時間あたりのログイン試行が規定の回数を超えたため、現在ログインが禁止されています。 " \
                   "しばらく待ってから再度ログインを試してください。"],
        })
      end
    end

    # RSpec.describe 'not allowed network' do
    #   let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '10.10.10.0/24') }

    #   it 'is failure' do
    #     response = action.call(params)
    #     expect(response.status).to eq 403
    #     expect(response.headers['Content-Type']).to eq "#{format}; charset=utf-8"
    #     json = JSON.parse(response.body.first, symbolize_names: true)
    #     expect(json).to eq({
    #       code: 403,
    #       message: 'Forbidden',
    #       errors: ['現在のネットワークからのログインは許可されていません。'],
    #     })
    #   end
    # end
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
      expect(json[:user]).to eq(user.to_h.except(:id))
      expect(Time.iso8601(json[:created_at])).to be_between(begin_time, end_time)
      expect(Time.iso8601(json[:updated_at])).to eq Time.iso8601(json[:created_at])
    end
  end

  context "when session timeout" do
    let(:session) {
      {
        uuid: uuid,
        user: user.name,
        created_at: Time.now - 7200,
        updated_at: Time.now - 7200,
      }
    }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 401,
        message: "Unauthorized",
        errors: ["セッションがタイムアウトしました。"],
      })
    end
  end
end
