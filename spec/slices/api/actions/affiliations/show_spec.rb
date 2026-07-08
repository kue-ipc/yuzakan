# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Show do
  init_action_spec

  let(:action_opts) {
    allow(affiliation_repo).to receive(:get!).with(affiliation.name).and_return(affiliation)
    {affiliation_repo: affiliation_repo}
  }
  let(:action_params) { {id: affiliation.name} }

  shared_context "when not exist" do
    let(:action_opts) {
      allow(affiliation_repo).to receive(:get!).with(affiliation.name).and_raise(Yuzakan::DB::Repo::NotFoundNameError)
      {affiliation_repo: affiliation_repo}
    }
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

  shared_examples "ok restricted" do
    it "is ok restricted" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Last-Modified"]).to eq affiliation.updated_at.httpdate
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        name: affiliation.name,
        label: affiliation.label,
      })
    end
  end

  shared_examples "ok current nil" do
    it "is ok with tilda id" do
      response = action.call({**params, id: "~"})
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Last-Modified"]).to eq affiliation.updated_at.httpdate
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to be_nil
    end
  end

  shared_examples "show" do
    it_behaves_like "ok"
    it_behaves_like "bad id param"

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "non-existent"
    end
  end

  shared_examples "show restricted" do
    it_behaves_like "ok restricted"
    it_behaves_like "bad id param"

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "non-existent"
    end
  end

  it_behaves_like "show restricted"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "show"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "show"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "show"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "show"
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
