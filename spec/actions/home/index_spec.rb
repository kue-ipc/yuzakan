# frozen_string_literal: true

RSpec.describe Yuzakan::Actions::Home::Index, :db do
  subject(:action) do
    described_class.new(
      config_repo: config_repo,
      network_repo: network_repo,
      user_repo: user_repo,
      activity_log_repo: activity_log_repo)
  end

  let(:params) do
    {"REMOTE_ADDR" => "192.168.0.1", "rack.session" => session}
  end

  let(:config_repo) do
    instance_double(Yuzakan::Repos::ConfigRepo, current: Factory[:config])
  end

  let(:network_repo) do
    instance_double(Yuzakan::Repos::NetworkRepo,
      find_include_address: Factory[:network])
  end

  let(:user_repo) do
    instance_double(Yuzakan::Repos::UserRepo, get: user)
  end

  let(:activity_log_repo) do
    instance_double(Yuzakan::Repos::ActivityLogRepo,
      create: Factory[:activity_log])
  end

  let(:user) do
    Factory[:user]
  end

  let(:session) do
    {
      uuid: "ffffffff-ffff-4fff-bfff-ffffffffffff",
      user: user.name,
      created_at: Time.now - 600,
      updated_at: Time.now - 60,
    }
  end

  it "is successful" do
    response = subject.call(params)
    expect(response).to be_successful
  end
end
