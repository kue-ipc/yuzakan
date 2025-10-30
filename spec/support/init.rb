# frozen_string_literal: true

# default let script

# request spec
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
      locked: false,
      unmanageable: false,
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

# action spec
def init_action_spec
  # response = action.call(params)
  # expect(response).to be_...

  subject(:action) { described_class.new(**base_action_opts, **action_opts) }

  let_structs
  let_mock_repos
  let_session

  let(:base_action_opts) {
    allow(config_repo).to receive(:current).and_return(config)
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
      "rack.session" => session,
      "REMOTE_ADDR" => client,
    }
  }

  let(:client) { "127.0.0.1" }

  # override if necessary for each action
  let(:action_opts) { {} }
  let(:action_params) { {} }

  # shared examples
  shared_examples "unauthorized" do
    it "is unauthorized" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({status: {code: 401, message: "Unauthorized"}})
    end
  end

  shared_examples "forbidden" do
    it "is forbidden" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 403
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({status: {code: 403, message: "Forbidden"}})
    end
  end

  shared_examples "not found" do
    it "is not found" do
      response = action.call(params)
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({status: {code: 404, message: "Not Found"}})
    end
  end

  shared_examples "unauthorized session timeout" do
    it "is unauthorized due to session timeout" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({status: {code: 401, message: "Unauthorized"}, flash: {warn: "セッションがタイムアウトしました。"}})
    end
  end

  shared_examples "bad id param" do
    it "is failure with tilda id" do
      response = action.call({**params, id: "~"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {id: ["形式が間違っています。"]}})
    end

    it "is failure with exclamation id" do
      response = action.call({**params, id: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {id: ["形式が間違っています。"]}})
    end

    it "is failure with over 255 id" do
      response = action.call({**params, id: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {id: ["サイズが255を超えてはいけません。"]}})
    end
  end

  shared_examples "bad id param without tilda" do
    it "is failure with exclamation id" do
      response = action.call({**params, id: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {id: ["形式が間違っています。 または ~と値が一致しません。"]}})
    end

    it "is failure with over 255 id" do
      response = action.call({**params, id: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {id: ["サイズが255を超えてはいけません。 または ~と値が一致しません。"]}})
    end
  end

  shared_examples "forbidden session timeout" do
    it "is forbidden due to session timeout" do
      response = action.call(params)
      expect(response.status).to eq 403
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({status: {code: 403, message: "Forbidden"}, flash: {warn: "セッションがタイムアウトしました。"}})
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

def init_operation_spec
  let_repo_mock
  let_structs
end

def init_part_spec
  let_structs

  subject { described_class.new(value:) }

  shared_examples "to_h with restrict" do
    it "to_h with restrict" do
      data = subject.to_h(restrict: true)
      expect(data).to eq({
        name: value.name,
        label: value.label,
      })
    end
  end

  shared_examples "to_json with restrict" do
    it "to_h with restrict" do
      json = subject.to_json(restrict: true)
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        name: value.name,
        label: value.label,
      })
    end
  end
end

# require user
def let_session
  let(:uuid) { "ffffffff-ffff-4fff-bfff-ffffffffffff" }
  let(:login_session) {
    {
      uuid: uuid,
      user: user.name,
      trusted: true,
      created_at: Time.now.to_i - 600,
      updated_at: Time.now.to_i - 60,
      expires_at: Time.now.to_i - 60 + 3600, # 1 hour later
    }
  }

  let(:session) { login_session }
  let(:logout_session) {
    {
      **login_session,
      user: nil,
      trusted: false,
    }
  }
  let(:first_session) { {} }
  let(:timeover_session) {
    {
      **login_session,
      created_at: Time.now.to_i - 7200,
      updated_at: Time.now.to_i - 7200,
      expires_at: Time.now.to_i - 7200 + 3600, # 1 hour later
    }
  }
end

# mock repostitories
#   create: struct,
#   update: struct | nil,
#   delete: struct | nil,
#   all: sturt[],
#   find: struct | nil,
#   first: struct | nil,
#   last: sturt | nil,
#   clear: integer
#   # and
#   get: struct | nil
#   set: sturct
#   unset: struct | nil
#   exist?: bool
#   list: string[]
# exist name: "#{name}42"
# not exist name: "hoge"
def let_mock_repos
  let(:config_repo) { instance_double(Yuzakan::Repos::ConfigRepo) }
  let(:network_repo) { instance_double(Yuzakan::Repos::NetworkRepo) }

  let(:affiliation_repo) {
    instance_double(Yuzakan::Repos::AffiliationRepo).tap do |repo|
      allow(repo).to receive(:exist?).with("affiliation42").and_return(true)
      allow(repo).to receive(:get).with("affiliation42").and_return(affiliation)
      allow(repo).to receive(:exist?).with("hoge").and_return(false)
      allow(repo).to receive(:get).with("hoge").and_return(nil)
    end
  }
  let(:group_repo) { instance_double(Yuzakan::Repos::GroupRepo) }
  let(:user_repo) { instance_double(Yuzakan::Repos::UserRepo) }
  let(:member_repo) { instance_double(Yuzakan::Repos::MemberRepo) }

  let(:service_repo) {
    instance_double(Yuzakan::Repos::ServiceRepo).tap do |repo|
      allow(repo).to receive(:all).and_return([service])
      allow(repo).to receive(:exist?).with("service42").and_return(true)
      allow(repo).to receive(:get).with("service42").and_return(service)
      allow(repo).to receive(:set).with("service42", anything).and_return(service)
      allow(repo).to receive(:exist?).with("hoge").and_return(false)
      # allow(repo).to receive(:get).with("hoge").and_return(nil)
      allow(repo).to receive(:set).with("hoge", anything).and_return(service)
      allow(repo).to receive(:transaction).and_yield
    end
  }
  let(:attr_repo) { instance_double(Yuzakan::Repos::AttrRepo) }
  let(:mapping_repo) { instance_double(Yuzakan::Repos::MappingRepo) }
  let(:auth_log_repo) { instance_double(Yuzakan::Repos::AuthLogRepo) }
  let(:action_log_repo) { instance_double(Yuzakan::Repos::ActionLogRepo) }

  # no database repos
  let(:adapter_repo) {
    instance_double(Yuzakan::AdapterRepo).tap do |repo|
      dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "dummy", class: Yuzakan::Adapters::Dummy)
      mock_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "mock", class: Yuzakan::Adapters::Mock)
      test_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "test", class: Yuzakan::Adapters::Test)
      vendor_dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "vendor.dummy", class: Yuzakan::Adapters::Dummy)

      allow(repo).to receive(:all).and_return([
        dummy_adapter,
        mock_adapter,
        test_adapter,
        vendor_dummy_adapter,
      ])
      allow(repo).to receive(:exist?).with("dummy").and_return(true)
      allow(repo).to receive(:get).with("dummy").and_return(dummy_adapter)
      allow(repo).to receive(:exist?).with("test").and_return(true)
      allow(repo).to receive(:get).with("test").and_return(test_adapter)
      allow(repo).to receive(:exist?).with("hoge").and_return(false)
    end
  }
end

# Factory.sturcts[:...]はROM::Struct::...になる。
# カスタマイズしたYuzakan::Sturcts::...は使わない。
def let_structs
  let(:config) { Factory.structs[:config] }
  let(:network) { Factory.structs[:network] }
  let(:affiliation) { Factory.structs[:affiliation] }
  let(:group) { Factory.structs[:group] }
  let(:user) { Factory.structs[:user] }
  let(:service) { Factory.structs[:service] }
  let(:attr) { Factory.structs[:attr] }
  let(:mapping) { Factory.structs[:mapping] }
  let(:auth_log) { Factory.structs[:auth_log] }
  let(:action_log) { Factory.structs[:action_log] }
  let(:attr_with_mappings) { Factory.structs[:attr_with_mappings] }
end
