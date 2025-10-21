# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Show do
  init_action_spec

  let(:action_opts) {
    allow(attr_repo).to receive_messages(get: attr)
    {attr_repo: attr_repo}
  }

  let(:action_params) { {id: "attr42"} }

  shared_context "when not exist" do
    let(:action_opts) {
      allow(attr_repo).to receive_messages(get: nil)
      {attr_repo: attr_repo}
    }
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
      })
    end

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "not found"
    end
  end

  shared_examples "ok restrict" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq(attr.to_h.slice(:name, :label, :category, :type))
    end

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "not found"
    end
  end

  it_behaves_like "ok restrict"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok restrict"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok restrict"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok"
  end
end
