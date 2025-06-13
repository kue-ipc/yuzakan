# frozen_string_literal: true

require "yaml"

RSpec.describe API::Actions::Self::Show do
  init_action_spec
  let(:action_opts) {
    {provider_repository: provider_repository,
     user_repository: user_repository,
     member_repository: member_repository,
     group_repository: group_repository,}
  }
  let(:format) { "application/json" }

  let(:providers) {
    [create_mock_provider(
      name: "provider",
      group: true,
      params: {
        username: "user", display_name: "ユーザー", email: "user@example.jp",
        primary_group: "group",
        groups: "admin, staff",
        attrs: YAML.dump({"jaDisplayName" => "表示ユーザー"}),
      },
      mappings: [{
        key: "jaDisplayName", conversion: nil,
        attr: {name: "ja_display_name", display_name: "日本語表示名", type: "string", hidden: false},
      }])]
  }
  let(:provider_repository) { instance_double(ProviderRepository, ordered_all_with_adapter_by_operation: providers) }
  let(:user_with_groups) {
    User.new(**user.to_h,
      members: [
        Member.new(primary: true, group: Group.new(name: "group")),
        Member.new(primary: false, group: Group.new(name: "admin")),
        Member.new(primary: false, group: Group.new(name: "staff")),
      ])
  }

  it "is successful" do
    allow(user_repository).to receive_messages(find_by_name: user, update: user, find_with_groups: user_with_groups)
    allow(user_repository).to receive(:transaction).and_yield

    response = action.call(params)
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({
      name: "user",
      display_name: "ユーザー",
      email: "user@example.jp",
      note: nil,
      prohibited: false,
      deleted: false,
      deleted_at: nil,
      clearance_level: 1,
      primary_group: "group",
      groups: ["group", "admin", "staff"],
      attrs: {ja_display_name: "表示ユーザー"},
      providers: {
        provider: {
          username: "user",
          display_name: "ユーザー",
          email: "user@example.jp",
          locked: false,
          unmanageable: false,
          mfa: false,
          primary_group: "group",
          groups: ["admin", "staff"],
          attrs: {ja_display_name: "表示ユーザー"},
        },
      },
    })
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end

  describe "no session" do
    let(:session) { {} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end

  describe "session timeout" do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 401,
        message: "Unauthorized",
        errors: ["セッションがタイムアウトしました。"],
      })
    end
  end
end
