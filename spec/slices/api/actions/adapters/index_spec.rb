# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Index do
  init_action_spec

  let(:action_opts) {
    # FIXME: アクションのDepsでは自動的に取得できないため、明示的に取得する。
    {adapter_repo: Hanami.app["adapter_repo"]}
  }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to contain_exactly(
        {name: "local", label: "ローカル"},
        {name: "ldap", label: "LDAP"},
        {name: "ad", label: "Active Directory"},
        {name: "posix_ldap", label: "Posix LDAP"},
        {name: "samba_ldap", label: "Samba LDAP"},
        {name: "google", label: "Google Workspace"},
        {name: "test", label: "テスト"},
        {name: "dummy", label: "ダミー"},
        {name: "mock", label: "モック"})
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
  end

  # test cases

  it_behaves_like "ok"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "index"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "index"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "index"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "index"
  end

  context "when logout" do
    include_context "when logout"
    it_behaves_like "unauthenticated"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "unauthenticated"
  end

  context "when timeover" do
    include_context "when timeover"
    it_behaves_like "session timeout"
  end
end
