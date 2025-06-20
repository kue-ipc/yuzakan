# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Index do
  init_action_spec

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq([
        {name: "ad",          displayName: "Active Directory"},
        {name: "dummy",       displayName: "ダミー"},
        {name: "google",      displayName: "Google Workspace"},
        {name: "ldap",        displayName: "LDAP"},
        {name: "local",       displayName: "ローカル"},
        {name: "mock",        displayName: "モック"},
        {name: "posix_ldap",  displayName: "Posix LDAP"},
        {name: "samba_ldap",  displayName: "Samba LDAP"},
        {name: "test",        displayName: "テスト"},
      ])
    end
  end

  it_behaves_like "ok"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok"
  end

  context "when logout" do
    include_context "when logout"
    it_behaves_like "forbidden"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "forbidden"
  end

  conthext "when timeover" do
    include_context "when timeover"
    it_behaves_like "session timeout"
  end
end
