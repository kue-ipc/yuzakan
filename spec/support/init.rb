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
  let(:provider) {
    Factory[:mock_provider, params: {
      username: user.name,
      password: password,
      display_name: user.display_name,
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
    provider
    rack_test_session.env "rack.session", session
    rack_test_session(:first).env "rack.session", first_session
    rack_test_session(:logout).env "rack.session", logout_session
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
    let(:user) { create_struct(:user, :guest) }
  end

  shared_context "when observer" do
    let(:user) { create_struct(:user, :observer) }
  end

  shared_context "when operator" do
    let(:user) { create_struct(:user, :operator) }
  end

  shared_context "when administrator" do
    let(:user) { create_struct(:user, :administrator) }
  end

  shared_context "when superuser" do
    let(:user) { create_struct(:user, :superuser) }
  end

  shared_context "when logout" do
    let(:session) { logout_session }
  end

  shared_context "when timeover" do
    let(:session) { timeover_session }
  end

  shared_context "when first" do
    let(:session) { first_session }
  end
end

def init_operation_spec
  let_repo_mock
  let_structs
end

def init_part_spec
  let_structs

  subject { described_class.new(value:) }
end

# require user
def let_session
  let(:login_session) {
    {
      uuid: uuid,
      user: user.name,
      trusted: true,
      created_at: Time.now - 600,
      updated_at: Time.now - 60,
    }
  }
  let(:logout_session) { {**login_session, user: nil, trusted: false} }
  let(:timeover_session) {
    {**login_session, created_at: Time.now - 7200, updated_at: Time.now - 7200}
  }
  let(:first_session) { {} }
  let(:session) { login_session }
  let(:uuid) { "ffffffff-ffff-4fff-bfff-ffffffffffff" }
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
def let_mock_repos
  let(:config_repo) { instance_double(Yuzakan::Repos::ConfigRepo) }
  let(:network_repo) { instance_double(Yuzakan::Repos::NetworkRepo) }
  let(:affiliation_repo) { instance_double(Yuzakan::Repos::AffiliationRepo) }
  let(:group_repo) { instance_double(Yuzakan::Repos::GroupRepo) }
  let(:user_repo) { instance_double(Yuzakan::Repos::UserRepo) }
  let(:member_repo) { instance_double(Yuzakan::Repos::MemberRepo) }
  let(:provider_repo) { instance_double(Yuzakan::Repos::ProviderRepo) }
  let(:attr_repo) { instance_double(Yuzakan::Repos::AttrRepo) }
  let(:mapping_repo) { instance_double(Yuzakan::Repos::MappingRepo) }
  let(:auth_log_repo) { instance_double(Yuzakan::Repos::AuthLogRepo) }
  let(:action_log_repo) { instance_double(Yuzakan::Repos::ActionLogRepo) }
end

# Factory.sturcts[:...]はROM::Struct::...になる。
# カスタマイズしたYuzakan::Sturcts::...は使わない。
def let_structs
  let(:config) { Factory.structs[:config] }
  let(:network) { Factory.structs[:network] }
  let(:affiliation) { Factory.structs[:affiliation] }
  let(:group) { Factory.structs[:group] }
  let(:user) { Factory.structs[:user] }
  let(:provider) { Factory.structs[:provider] }
  let(:attr) { Factory.structs[:attr] }
  let(:mapping) { Factory.structs[:mapping] }
  let(:auth_log) { Factory.structs[:auth_log] }
  let(:action_log) { Factory.structs[:action_log] }
end
