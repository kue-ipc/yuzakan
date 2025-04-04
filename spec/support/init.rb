# frozen_string_literal: true

# default let script

# request spec
def init_feature_spec
  # default REMOTE_ADDR: 127.0.0.1

  let(:config) { Factory[:config] }
  # trusted level 5 network 127.0.0.0/8
  let(:network) { Factory[:network_ipv4_loopback] }
  before do
    config
    network
  end
end

# request spec
def init_request_spec
  # default REMOTE_ADDR: 127.0.0.1

  let(:user) { Factory[:user] }
  let(:password) { Faker::Internet.password }
  let(:config) { Factory[:config] }
  # trusted level 5 network 127.0.0.0/8
  let(:network) { Factory[:network_ipv4_loopback] }
  let(:session) {
    {
      uuid: uuid,
      user: user.name,
      trusted: true,
      created_at: Time.now - 600,
      updated_at: Time.now - 60,
    }
  }
  let(:uuid) { "ffffffff-ffff-4fff-bfff-ffffffffffff" }
  let(:group) { Factory[:group] }
  let(:provider) {
    Factory[:provdire_mock, params: {
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
    rack_test_session(:first).env "rack.session", {}
    rack_test_session(:logout).env "rack.session", {**session, user: nil}
    rack_test_session(:timeover).env "rack.session",
      {**session, created_at: Time.now - 7200, updated_at: Time.now - 7200}
  end
end

# action spec
def init_action_spec
  # response = action.call(params)
  # expect(response).to be_...

  subject(:action) { described_class.new(**base_action_opts, **action_opts) }

  let_structs
  let_mock_repos

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
  let(:network) { Factory.structs[:network_trusted] }

  let(:params) { {**action_params, **env} }
  let(:env) {
    {
      "rack.session" => session,
      "REMOTE_ADDR" => client,
    }
  }
  let(:session) {
    {
      uuid: uuid,
      user: user.name,
      created_at: Time.now - 600,
      updated_at: Time.now - 60,
    }
  }
  let(:uuid) { "ffffffff-ffff-4fff-bfff-ffffffffffff" }
  let(:client) { "127.0.0.1" }

  # override if necessary for each action
  let(:action_opts) { {} }
  let(:action_params) { {} }
end

def init_operation_spec
  let_repo_mock
  let_structs
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
  let(:attr_mapping_repo) { instance_double(Yuzakan::Repos::AttrMappingRepo) }
  let(:auth_log_repo) { instance_double(Yuzakan::Repos::AuthLogRepo) }
  let(:action_log_repo) { instance_double(Yuzakan::Repos::ActionLogRepo) }
end

def let_structs
  let(:config) { Factory.structs[:config] }
  let(:network) { Factory.structs[:network] }
  let(:affiliation) { Factory.structs[:affiliation] }
  let(:group) { Factory.structs[:group] }
  let(:user) { Factory.structs[:user] }
  let(:provider) { Factory.structs[:provider] }
  let(:attr) { Factory.structs[:attr] }
  let(:auth_log) { Factory.structs[:auth_log] }
  let(:action_log) { Factory.structs[:action_log] }
end
