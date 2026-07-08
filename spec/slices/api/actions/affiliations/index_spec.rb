# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Index do
  init_action_spec
  let_pager

  let(:action_opts) { {affiliation_repo: affiliation_repo} }

  before do
    allow(affiliation_repo).to receive(:index).and_return([[affiliation], pager])
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Total-Count"]).to eq pager.total.to_s
      expect(response.headers["Total-Pages"]).to eq pager.total_pages.to_s
      expect(response.headers["Current-Page"]).to eq pager.current_page.to_s
      expect(response.headers["Per-Page"]).to eq pager.per_page.to_s
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq([{name: affiliation.name, label: affiliation.label}])
    end

    it "is ok with params" do
      response = action.call({**params, page: 2, per_page: 50, order: "name.desc", search: "aff", match: "extract"})
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Total-Count"]).to eq pager.total.to_s
      expect(response.headers["Total-Pages"]).to eq pager.total_pages.to_s
      expect(response.headers["Current-Page"]).to eq pager.current_page.to_s
      expect(response.headers["Per-Page"]).to eq pager.per_page.to_s
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq([{name: affiliation.name, label: affiliation.label}])
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
  end

  # test cases

  it_behaves_like "unauthorized"

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
