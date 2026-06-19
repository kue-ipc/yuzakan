# frozen_string_literal: true

# default init script

# action spec
def init_action_spec
  # response = action.call(params)
  # expect(response).to be_...

  subject(:action) { described_class.new(**base_action_opts, **action_opts) }

  let_session
  let_structs
  let_mock_repos

  let(:base_action_opts) {
    allow(config_repo).to receive(:current!).and_return(config)
    allow(network_repo).to receive(:find_include).and_return(network)
    allow(user_repo).to receive(:get).with(user.name).and_return(user)
    allow(action_log_repo).to receive(:create).and_return(action_log)
    {
      config_repo: config_repo,
      network_repo: network_repo,
      user_repo: user_repo,
      action_log_repo: action_log_repo,
    }
  }
  let(:network) { Factory.structs[:trusted_network] }

  let(:params) { {**action_params, **env} }
  let(:env) {
    {
      "rack.session" => session.transform_keys(&:to_s),
      "REMOTE_ADDR" => client,
    }
  }

  let(:client) { "127.0.0.1" }

  # override if necessary for each action
  let(:action_opts) { {} }
  let(:action_params) { {} }

  # shared examples
  shared_examples "unauthenticated" do
    it "is unauthorized due to unauthenticated" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "ログインが必要です。",
      })
    end
  end

  shared_examples "untrusted" do
    it "is unauthorized due to untrusted" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "多要素認証が必要です",
      })
    end
  end

  shared_examples "unauthorized" do
    it "is forbidden due to unauthorized" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 403
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "権限がありません。",
      })
    end
  end

  shared_examples "non-existent" do
    it "is not found due to non-existent" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "指定のエンタイティはありません。",
      })
    end
  end

  shared_examples "session timeout" do
    it "is unauthorized due to session timeout" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "セッションがタイムアウトしました。",
      })
    end
  end

  shared_examples "bad id param" do
    it "is failure due to tilda id" do
      response = action.call({**params, id: "~"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {id: ["形式が間違っています。"]},
      })
    end

    it "is failure due to exclamation id" do
      response = action.call({**params, id: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {id: ["形式が間違っています。"]},
      })
    end

    it "is failure due to over 255 id" do
      response = action.call({**params, id: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {id: ["サイズが255を超えてはいけません。"]},
      })
    end
  end

  shared_examples "bad id param without tilda" do
    it "is failure due to exclamation id" do
      response = action.call({**params, id: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {id: ["形式が間違っています。 または ~と値が一致しません。"]},
      })
    end

    it "is failure due to over 255 id" do
      response = action.call({**params, id: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        message: "パラメーターが不正です。",
        invalid: {id: ["形式が間違っています。 または ~と値が一致しません。"]},
      })
    end
  end

  shared_context "when guest" do
    let(:user) { Factory.structs[:guest] }
  end

  shared_context "when observer" do
    let(:user) { Factory.structs[:observer] }
  end

  shared_context "when operator" do
    let(:user) { Factory.structs[:operator] }
  end

  shared_context "when administrator" do
    let(:user) { Factory.structs[:administrator] }
  end

  shared_context "when superuser" do
    let(:user) { Factory.structs[:superuser] }
  end

  shared_context "when logout" do
    let(:session) { logout_session }
  end

  shared_context "when first" do
    let(:session) { first_session }
  end

  shared_context "when timeover" do
    let(:session) { timeover_session }
  end

  shared_context "when current id" do
    let(:action_params) { {id: "~"} }
  end
end

# feacture spec
def init_feature_spec
  # default REMOTE_ADDR: 127.0.0.1

  let(:config) { Factory[:config] }
  # trusted level 5 network 127.0.0.0/8
  let(:network) { Factory[:ipv4_loopback_network] }
  before do
    config
    network
  end
end

# operation spec
def init_operation_spec
  let_repo_mock
  let_structs
end

# request spec
def init_request_spec
  # default REMOTE_ADDR: 127.0.0.1

  let_session

  let(:user) { Factory[:user] }
  let(:password) { Faker::Internet.password }
  let(:config) { Factory[:config] }
  # trusted level 5 network 127.0.0.0/8
  let(:network) { Factory[:ipv4_loopback_network] }
  let(:group) { Factory[:group] }
  let(:service) {
    Factory[:mock_service, params: {
      check: true,
      username: user.name,
      password: password,
      label: user.label,
      email: user.email,
      unmanageable: false,
      locked: false,
      mfa: false,
      primary_group: group.name,
      groups: "",
      attrs: "{}",
    }]
  }

  before do
    user
    config
    network
    service
    rack_test_session.env "rack.session", session
    rack_test_session(:logout).env "rack.session", logout_session
    rack_test_session(:first).env "rack.session", first_session
    rack_test_session(:timeover).env "rack.session", timeover_session
  end
end

# part spec
def init_part_spec
  # data = subject.to_h(**opts)
  #   or
  # json = subject.to_json(**opts)
  # data = JSON.parse(json, symbolize_names: true)
  # expect(data).to eq({...})
  subject { described_class.new(value:) }

  let_structs
  let(:opts) { {} }
  let(:full_data) { value.to_h }
  let(:simple_data) {
    {
      name: value.name,
      label: value.label,
    }
  }

  shared_examples "full data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq(full_data)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq(full_data)
    end
  end

  shared_examples "simple data" do
    it "to_h" do
      data = subject.to_h(**opts)
      expect(data).to eq(simple_data)
    end

    it "to_json" do
      json = subject.to_json(**opts)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq(simple_data)
    end
  end
end

# view spec
def init_view_spec
  raise "not implemented"
end
