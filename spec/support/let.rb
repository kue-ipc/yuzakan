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

def let_mock_repos
  let(:config_repo) { instance_double(Yuzakan::Repos::ConfigRepo) }
  let(:network_repo) { instance_double(Yuzakan::Repos::NetworkRepo) }

  let(:affiliation_repo) { instance_double(Yuzakan::Repos::AffiliationRepo) }
  let(:group_repo) { instance_double(Yuzakan::Repos::GroupRepo) }
  let(:user_repo) { instance_double(Yuzakan::Repos::UserRepo) }
  let(:member_repo) { instance_double(Yuzakan::Repos::MemberRepo) }

  let(:service_repo) { instance_double(Yuzakan::Repos::ServiceRepo) }

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
