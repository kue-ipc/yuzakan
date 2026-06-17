# frozen_string_literal: true

# default let script

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
def let_mock_repos
  let(:config_repo) { instance_double(Yuzakan::Repos::ConfigRepo) }
  let(:network_repo) { instance_double(Yuzakan::Repos::NetworkRepo) }

  let(:affiliation_repo) {
    instance_double(Yuzakan::Repos::AffiliationRepo)
    # .tap do |repo|
    #   allow(repo).to receive(:exist?).with("affiliation42").and_return(true)
    #   allow(repo).to receive(:get).with("affiliation42").and_return(affiliation)
    #   allow(repo).to receive(:exist?).with("hoge").and_return(false)
    #   allow(repo).to receive(:get).with("hoge").and_return(nil)
    # end
  }
  let(:group_repo) { instance_double(Yuzakan::Repos::GroupRepo) }
  let(:user_repo) { instance_double(Yuzakan::Repos::UserRepo) }
  let(:member_repo) { instance_double(Yuzakan::Repos::MemberRepo) }

  let(:service_repo) {
    instance_double(Yuzakan::Repos::ServiceRepo)
    # .tap do |repo|
    #   allow(repo).to receive_messages(
    #     all: [service, another_service],
    #     get: nil, set: service, unset: nil, exist?: false,
    #     last_order: 42, renumber_order: 0)
    #   allow(repo).to receive(:transaction).and_yield

    #   allow(repo).to receive(:get).with("service42").and_return(service)
    #   # allow(repo).to receive(:set).with("service42", anything).and_return(service)
    #   allow(repo).to receive(:unset).with("service42").and_return(service)
    #   allow(repo).to receive(:exist?).with("service42").and_return(true)
    # end
  }
  let(:attr_repo) { instance_double(Yuzakan::Repos::AttrRepo) }
  let(:mapping_repo) { instance_double(Yuzakan::Repos::MappingRepo) }
  let(:auth_log_repo) { instance_double(Yuzakan::Repos::AuthLogRepo) }
  let(:action_log_repo) { instance_double(Yuzakan::Repos::ActionLogRepo) }

  # no database repos
  let(:adapter_repo) {
    instance_double(Yuzakan::AdapterRepo)
    # .tap do |repo|
    #   dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "dummy", class: Yuzakan::Adapters::Dummy)
    #   mock_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "mock", class: Yuzakan::Adapters::Mock)
    #   test_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "test", class: Yuzakan::Adapters::Test)
    #   vendor_dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "vendor.dummy", class: Yuzakan::Adapters::Dummy)

    #   allow(repo).to receive(:all).and_return([
    #     dummy_adapter,
    #     mock_adapter,
    #     test_adapter,
    #     vendor_dummy_adapter,
    #   ])
    #   allow(repo).to receive(:exist?).with("dummy").and_return(true)
    #   allow(repo).to receive(:get).with("dummy").and_return(dummy_adapter)
    #   allow(repo).to receive(:exist?).with("test").and_return(true)
    #   allow(repo).to receive(:get).with("test").and_return(test_adapter)
    #   allow(repo).to receive(:exist?).with("hoge").and_return(false)
    # end
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
  let(:member) { Factory.structs[:member] }

  let(:service) { Factory.structs[:service] }
  let(:managed_group) { Factory.structs[:managed_group] }
  let(:managed_user) { Factory.structs[:managed_user] }

  let(:attr) { Factory.structs[:attr] }
  let(:mapping) { Factory.structs[:mapping] }

  let(:dictionary) { Factory.structs[:dictionary] }
  let(:term) { Factory.structs[:term] }

  let(:action_log) { Factory.structs[:action_log] }
  let(:auth_log) { Factory.structs[:auth_log] }

  # another
  # let(:another_network) { Factory.structs[:another_network] }
  # let(:another_affiliation) { Factory.structs[:another_affiliation] }
  # let(:another_group) { Factory.structs[:another_group] }
  # let(:another_user) { Factory.structs[:another_user] }
  let(:another_service) { Factory.structs[:another_service] }
  # let(:another_attr) { Factory.structs[:another_attr] }
  # let(:another_mapping) { Factory.structs[:another_mapping] }
  # let(:another_auth_log) { Factory.structs[:another_auth_log] }
  # let(:another_action_log) { Factory.structs[:another_action_log] }
end

def let_pager
  let(:pager) {
    instance_double(ROM::SQL::Plugin::Pagination::Pager).tap do |pager|
      allow(pager).to receive_messages(current_page: 2, per_page: 20,
        total_pages: 5, total: 100, first_in_page: 21, last_in_page: 40)
    end
  }
end
