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
end

def init_operation_spec
  let_repo_mock
  let_structs
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
  let(:attr_mapping_repo) { instance_double(Yuzakan::Repos::AttrMappingRepo) }
  let(:auth_log_repo) { instance_double(Yuzakan::Repos::AuthLogRepo) }
  let(:action_log_repo) { instance_double(Yuzakan::Repos::ActionLogRepo) }
end

def create_struct(struct_name, factory_name = nil)
  inflector = Yuzakan::App["inflector"]
  factory_name ||= struct_name.intern
  class_name = inflector.classify(struct_name)
  if Yuzakan::Structs.const_defined?(class_name)
    # カスタマイズされたStructを使用してstructを作成する。
    relation = Hanami.app["relations.#{inflector.pluralize(struct_name)}"]
    attributes = Factory.structs[factory_name].attributes
    superclass = Yuzakan::Structs.const_get(inflector.classify(struct_name))
    Class.new(superclass) do
      attributes.each_key { |key| attribute key, relation[key].type }
    end.new(**attributes)
  else
    # Factoryで定義されているstructをそのまま使用する。
    Factory.structs[factory_name]
  end
end

# そのままの場合はROM::Structになるため、カスタマイズした属性を使用するために、
# create_struct経由にする。
def let_structs
  let(:config) { create_struct(:config) }
  let(:network) { create_struct(:network) }
  let(:affiliation) { create_struct(:affiliation) }
  let(:group) { create_struct(:group) }
  let(:user) { create_struct(:user) }
  let(:provider) { create_struct(:provider) }
  let(:attr) { create_struct(:attr) }
  let(:auth_log) { create_struct(:auth_log) }
  let(:action_log) { create_struct(:action_log) }
end
