# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Destroy do
  init_action_spec

  let(:action_opts) {
    allow(affiliation_repo).to receive(:unset!).with(affiliation.name).and_return(affiliation)
    {affiliation_repo: affiliation_repo}
  }
  let(:action_params) { {id: affiliation.name} }

  shared_context "when not exist" do
    let(:action_opts) {
      allow(affiliation_repo).to receive(:unset!).with(affiliation.name).and_raise(Yuzakan::DB::Repo::NotFoundNameError)
      {affiliation_repo: affiliation_repo}
    }
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 204
    end
  end

  # rubocop:disable RSpec/IncludeExamples
  shared_examples "destroy" do
    include_examples "ok"
    include_examples "bad id param"

    context "when not exist" do
      include_context "when not exist"
      include_examples "non-existent"
    end
  end
  # rubocop:enable RSpec/IncludeExamples

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
    it_behaves_like "destroy"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "destroy"
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
