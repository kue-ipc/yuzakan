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
  let(:action_params) { {username: "user", password: "pass"} }

  let(:format) { "application/json" }

  let(:auth_log_repo_stubs) { {create: auth_log, recent: []} }

  let(:sync_user) { instance_double(Yuzakan::Management::SyncUser) }
  let(:authenticate) { instance_double(Yuzakan::Providers::Authenticate) }

  it "is redirection (see other)" do
    response = action.call(params)
    expect(response).to be_redirection
    expect(response.status).to eq 303
    expect(response.headers["Location"]).to eq "/api/session"
    expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
    expect(JSON.parse(response.body.first, symbolize_names: true)).to eq({
      status: 303,
      message: "See Other",
      location: "/api/session",
    })
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is successful" do
      begin_time = Time.now.floor
      response = action.call(params)
      end_time = Time.now.floor
      expect(response[0]).to eq 201
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json[:uuid]).to eq uuid
      expect(json[:current_user]).to eq(user.to_h.except(:id))
      created_at = Time.iso8601(json[:created_at])
      expect(created_at).to be >= begin_time
      expect(created_at).to be <= end_time
      updated_at = Time.iso8601(json[:updated_at])
      expect(updated_at).to be >= begin_time
      expect(updated_at).to be <= end_time
      deleted_at = Time.iso8601(json[:deleted_at])
      expect(deleted_at).to be >= begin_time + 3600
      expect(deleted_at).to be <= end_time + 3600
    end

    it "is failed with bad username" do
      response = action.call(**params, username: "baduser")
      expect(response[0]).to eq 422
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 422,
        message: "Unprocessable Entity",
        errors: ["ユーザー名またはパスワードが違います。"],
      })
    end

    it "is failed with bad password" do
      response = action.call(**params, password: "badpass")
      expect(response[0]).to eq 422
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 422,
        message: "Unprocessable Entity",
        errors: ["ユーザー名またはパスワードが違います。"],
      })
    end

    it "is error with no username" do
      response = action.call(**params.except(:username))
      expect(response[0]).to eq 400
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{username: ["存在しません。"]}],
      })
    end

    it "is error with no password" do
      response = action.call(**params.except(:password))
      expect(response[0]).to eq 400
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{password: ["存在しません。"]}],
      })
    end

    it "is error with too large username" do
      response = action.call(**params, username: "user" * 64)
      expect(response[0]).to eq 400
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{username: ["サイズが255を超えてはいけません。"]}],
      })
    end

    it "is error with empty password" do
      response = action.call(**params, password: "")
      expect(response[0]).to eq 400
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
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
        expect(response[0]).to eq 403
        expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
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
    #     expect(response[0]).to eq 403
    #     expect(response[1]['Content-Type']).to eq "#{format}; charset=utf-8"
    #     json = JSON.parse(response[2].first, symbolize_names: true)
    #     expect(json).to eq({
    #       code: 403,
    #       message: 'Forbidden',
    #       errors: ['現在のネットワークからのログインは許可されていません。'],
    #     })
    #   end
    # end
  end

  describe "no session" do
    let(:session) { {} }

    it "is successful" do
      begin_time = Time.now.floor
      response = action.call(params)
      end_time = Time.now.floor
      expect(response[0]).to eq 201
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json[:uuid]).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(json[:current_user]).to eq(user.to_h.except(:id))
      created_at = Time.iso8601(json[:created_at])
      expect(created_at).to be >= begin_time
      expect(created_at).to be <= end_time
      updated_at = Time.iso8601(json[:updated_at])
      expect(updated_at).to be >= begin_time
      expect(updated_at).to be <= end_time
      deleted_at = Time.iso8601(json[:deleted_at])
      expect(deleted_at).to be >= begin_time + 3600
      expect(deleted_at).to be <= end_time + 3600
    end
  end

  describe "session timeout" do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it "is error" do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        code: 401,
        message: "Unauthorized",
        errors: ["セッションがタイムアウトしました。"],
      })
    end
  end
end
