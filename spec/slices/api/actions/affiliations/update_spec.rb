# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Update do
  init_action_spec

  before do
    allow(affiliation_repo).to receive(:get!).with(affiliation.name).and_return(affiliation)
    allow(affiliation_repo).to receive(:put!).with(affiliation.name, **affiliation_params).and_return(affiliation)
    allow(complete_affiliation).to \
      receive(:call).with(affiliation.name, affiliation.attrs).and_return(Success(affiliation.attrs))
  end

  let(:action_opts) { {affiliation_repo: affiliation_repo, complete_affiliation: complete_affiliation} }
  let(:action_params) { {id: affiliation.name, **affiliation_params} }

  let(:affiliation_params) { {note: affiliation.note, attrs: affiliation.attrs} }

  let(:complete_affiliation) { instance_double(Yuzakan::Management::CompleteAffiliation) }

  shared_context "when not exist" do
    before do
      allow(affiliation_repo).to receive(:get!).with(affiliation.name).and_raise(Yuzakan::DB::Repo::NotFoundNameError)
      # allow(affiliation_repo).to \
      #   receive(:put!).with(affiliation.name, **affiliation_params).and_raise(Yuzakan::DB::Repo::NotFoundNameError)
    end
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Last-Modified"]).to eq affiliation.updated_at.httpdate
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        name: affiliation.name,
        label: affiliation.label,
        note: affiliation.note,
        attrs: affiliation.attrs,
      })
    end
  end

  shared_examples "update" do
    it_behaves_like "ok"
    it_behaves_like "bad id param"

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "non-existent"
    end
  end

  it_behaves_like "unauthorized"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "unauthorized"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "unauthorized"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "update"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "update"
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
